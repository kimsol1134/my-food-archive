#!/usr/bin/env ruby

require "open3"
require "pathname"
require "uri"

ROOT = Pathname.new(__dir__).join("..").expand_path
BOOK_RELEASE = "book-v1.0.1"

errors = []

def read(relative)
  ROOT.join(relative).read
end

required_files = %w[
  README.md
  START_HERE.md
  LICENSE
  pubspec.lock
  docs/PRD.md
  docs/TRD.md
  docs/TRD_android.md
  docs/Implement_plan.md
  docs/Implement_plan_android.md
  docs/AppStore_Submission_Checklist.md
  docs/privacy-policy.md
  docs/android/README.md
  site/index.html
  site/support/index.html
  site/android/index.html
  .github/ISSUE_TEMPLATE/book-help.yml
  .github/ISSUE_TEMPLATE/errata.yml
]

missing = required_files.reject { |path| ROOT.join(path).file? }
errors << "Required publication files are missing: #{missing.join(', ')}" unless missing.empty?

readme = read("README.md")
start_here = read("START_HERE.md")
site_home = read("site/index.html")
support = read("site/support/index.html")
license = read("LICENSE")

["README.md", "START_HERE.md", "site/index.html"].each do |path|
  content = read(path)
  errors << "#{path} does not point to #{BOOK_RELEASE}" unless content.include?(BOOK_RELEASE)
end

fixed_zip = "https://github.com/kimsol1134/my-food-archive/archive/refs/tags/#{BOOK_RELEASE}.zip"
errors << "README.md has no fixed book ZIP link" unless readme.include?(fixed_zip)
errors << "START_HERE.md has no fixed book ZIP link" unless start_here.include?(fixed_zip)
errors << "site/index.html has no fixed book ZIP link" unless site_home.include?(fixed_zip)

errors << "README.md does not lead first-time readers to START_HERE.md" unless readme.include?("START_HERE.md")
errors << "Reader site does not lead first-time readers to /start/" unless site_home.include?("./start/")

if readme.include?("Windows 또는 Android 독자") || start_here.include?("Windows 또는 Android 독자")
  errors << "Computer environment and app target are combined into one reader label"
end

unless readme.include?("iPhone 앱은 Mac에서") && readme.include?("Android 앱은 Mac 또는 Windows에서")
  errors << "README.md does not clearly separate computer environment from app target"
end

version_match = read("pubspec.yaml").match(/^version:\s*([0-9.]+)\+([0-9]+)$/)
if version_match
  app_version = version_match[1]
  build_number = version_match[2]
  expected_support_text = "완성 앱 버전: #{app_version} (빌드 #{build_number})"
  errors << "Support page app version does not match pubspec.yaml" unless support.include?(expected_support_text)
else
  errors << "pubspec.yaml has no readable app version"
end

podfile = read("ios/Podfile")
ios_15_declared = podfile.match?(/platform\s+:ios,\s*['\"]15\.0['\"]/)
unless ios_15_declared
  errors << "iOS Podfile deployment target is not 15.0"
end

xcode_targets = read("ios/Runner.xcodeproj/project.pbxproj")
  .scan(/IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);/)
  .flatten
  .map(&:to_f)
if xcode_targets.empty? || xcode_targets.any? { |version| version < 15.0 }
  errors << "Xcode deployment targets must all be iOS 15.0 or later"
end

android_gradle = read("android/app/build.gradle.kts")
errors << "Android compileSdk must be 36" unless android_gradle.match?(/compileSdk\s*=\s*36/)
unless android_gradle.match?(/targetSdk\s*=\s*(?:36|flutter\.targetSdkVersion)/)
  errors << "Android targetSdk must use API 36 or Flutter's current stable default"
end

main_dart = read("lib/main.dart")
errors << "Android release App Check must use Play Integrity" unless main_dart.include?("AndroidPlayIntegrityProvider")
unless main_dart.include?("AppleAppAttestWithDeviceCheckFallbackProvider")
  errors << "iOS release App Check must use App Attest with DeviceCheck fallback"
end

unless readme.include?("MIT License") && license.include?("MIT License") && license.include?("Documentation and media")
  errors << "Source-code and documentation/media license terms are not both visible"
end

tracked, git_error = Open3.capture2e("git", "ls-files", chdir: ROOT.to_s)
if git_error.success?
  sensitive_names = tracked.lines.map(&:strip).select do |path|
    basename = File.basename(path).downcase
    basename == "key.properties" ||
      basename == ".env" ||
      basename.start_with?(".env.") ||
      basename.end_with?(".jks", ".keystore", ".p12", ".mobileprovision") ||
      basename.match?(/service.?account.*\.json/)
  end
  errors << "Sensitive local files are tracked: #{sensitive_names.join(', ')}" unless sensitive_names.empty?
else
  errors << "Could not list tracked files: #{tracked.strip}"
end

secret_output, secret_status = Open3.capture2e(
  "git", "grep", "-n", "-I", "-E",
  "BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY|\"type\"[[:space:]]*:[[:space:]]*\"service_account\"|\"private_key\"[[:space:]]*:|AKIA[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{30,}|sk-[A-Za-z0-9]{20,}",
  chdir: ROOT.to_s
)
errors << "Possible private credential found:\n#{secret_output}" if secret_status.success? && !secret_output.empty?

public_text_paths = %w[README.md START_HERE.md docs site .github/ISSUE_TEMPLATE]
path_output, path_status = Open3.capture2e(
  "rg", "-n", "/Users/solkim|/private/tmp|/tmp/mfa-publication", *public_text_paths,
  chdir: ROOT.to_s
)
errors << "Local machine path found in public material:\n#{path_output}" if path_status.success? && !path_output.empty?

markdown_files = if git_error.success?
                   tracked.lines.map(&:strip).select { |path| path.end_with?(".md") }
                 else
                   []
                 end

markdown_files.each do |relative|
  source = ROOT.join(relative)
  content = source.read
  targets = content.scan(/!?\[[^\]]*\]\(([^)]+)\)/).flatten
  targets += content.scan(/<(?:a|img)\b[^>]*(?:href|src)="([^"]+)"/i).flatten

  targets.each do |target|
    target = target.strip.split(/\s+["']/, 2).first
    next if target.empty? || target.start_with?("#", "mailto:") || target.match?(/\A[a-z][a-z0-9+.-]*:/i)

    path = target.split(/[?#]/, 2).first
    next if path.empty?

    decoded = URI.decode_www_form_component(path)
    destination = source.dirname.join(decoded).cleanpath
    errors << "#{relative} has a missing local link: #{target}" unless destination.exist?
  rescue ArgumentError
    errors << "#{relative} has an invalid local link: #{target}"
  end
end

preview_images = %w[
  docs/book-screenshots/android-app/a-01-home.png
  docs/book-screenshots/android-app/a-03-gemini-result.png
  docs/book-screenshots/android-app/a-04-saved.png
]

preview_images.each do |relative|
  path = ROOT.join(relative)
  next unless path.file?

  data = path.binread(24)
  unless data.start_with?("\x89PNG\r\n\x1A\n".b) && data.bytesize >= 24
    errors << "Preview image is not a valid PNG: #{relative}"
    next
  end

  width, height = data.byteslice(16, 8).unpack("NN")
  errors << "Preview image is too small for publication: #{relative} (#{width}x#{height})" if width < 1000 || height < 1800
end

if errors.empty?
  puts "Publication readiness check passed"
  puts "- fixed book snapshot: #{BOOK_RELEASE}"
  puts "- beginner entry points: README, START_HERE, reader site, support FAQ"
  puts "- platform baselines: iOS 15+, Android API 36"
  puts "- local links, private credentials, preview images: checked"
else
  warn errors.map { |error| "- #{error}" }.join("\n")
  exit 1
end
