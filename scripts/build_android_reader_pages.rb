#!/usr/bin/env ruby

require "cgi"
require "fileutils"
require "kramdown"
require "kramdown-parser-gfm"
require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
OUTPUT_ROOT = Pathname.new(ENV.fetch("OUTPUT_ROOT", ROOT.join("site").to_s)).expand_path
SITE_PUBLIC_ROOT = "/my-food-archive"
ANDROID_PUBLIC_ROOT = "#{SITE_PUBLIC_ROOT}/android"
RAW_ROOT = "https://raw.githubusercontent.com/kimsol1134/my-food-archive/main"
GITHUB_ROOT = "https://github.com/kimsol1134/my-food-archive"

PAGES = {
  ROOT.join("START_HERE.md") => {
    output: "start",
    public_path: "#{SITE_PUBLIC_ROOT}/start",
    title: "책 독자라면 여기부터",
    description: "《클로드 코드로 앱스토어까지》 독자를 위한 My Food Archive 실습 자료 시작 안내",
    nav_path: "#{SITE_PUBLIC_ROOT}/",
    nav_label: "← 공식 실습 자료 첫 화면"
  },
  ROOT.join("docs/privacy-policy.md") => {
    output: "privacy-policy",
    public_path: "#{SITE_PUBLIC_ROOT}/privacy-policy",
    title: "개인정보처리방침",
    description: "My Food Archive 개인정보처리방침",
    nav_path: "#{SITE_PUBLIC_ROOT}/",
    nav_label: "← 공식 실습 자료 첫 화면"
  },
  ROOT.join("docs/android/README.md") => {
    output: "android/overview",
    public_path: "#{ANDROID_PUBLIC_ROOT}/overview",
    title: "책과 온라인 자료를 함께 읽는 순서"
  },
  ROOT.join("docs/android/google-play-internal-test-guide.md") => {
    output: "android/internal-test",
    public_path: "#{ANDROID_PUBLIC_ROOT}/internal-test",
    title: "15~16장 · Google Play 내부 테스트"
  },
  ROOT.join("docs/android/release-roadmap.md") => {
    output: "android/release",
    public_path: "#{ANDROID_PUBLIC_ROOT}/release",
    title: "17~18장 · 비공개 테스트와 공개"
  },
  ROOT.join("docs/android/app-screenshot-reference.md") => {
    output: "android/app-screenshots",
    public_path: "#{ANDROID_PUBLIC_ROOT}/app-screenshots",
    title: "Android 앱 화면 참고본"
  },
  ROOT.join("docs/android/tester-recruitment.md") => {
    output: "android/tester-recruitment",
    public_path: "#{ANDROID_PUBLIC_ROOT}/tester-recruitment",
    title: "Google Play 비공개 테스터 모집"
  }
}.freeze

def strip_front_matter(markdown)
  return markdown unless markdown.start_with?("---\n")

  markdown.sub(/\A---\n.*?\n---\n/m, "")
end

def rewrite_target(target, source)
  return target if target.empty? || target.start_with?("#", "/", "mailto:") || target.match?(/\A[a-z][a-z0-9+.-]*:/i)

  path, fragment = target.split("#", 2)
  absolute = source.dirname.join(path).cleanpath
  suffix = fragment ? "##{fragment}" : ""

  if PAGES.key?(absolute)
    public_path = PAGES.fetch(absolute).fetch(:public_path)
    return "#{public_path}/#{suffix}"
  end

  relative = absolute.relative_path_from(ROOT).to_s
  if absolute.directory?
    "#{GITHUB_ROOT}/tree/main/#{relative}#{suffix}"
  elsif absolute.extname == ".md"
    "#{GITHUB_ROOT}/blob/main/#{relative}#{suffix}"
  else
    "#{RAW_ROOT}/#{relative}#{suffix}"
  end
end

def rewrite_relative_urls(html, source)
  html.gsub(/\b(href|src)="([^"]+)"/) do
    attribute = Regexp.last_match(1)
    target = Regexp.last_match(2)
    %(#{attribute}="#{CGI.escapeHTML(rewrite_target(target, source))}")
  end
end

def page_template(config, body)
  title = config.fetch(:title)
  escaped_title = CGI.escapeHTML(title)
  escaped_description = CGI.escapeHTML(
    config.fetch(:description, "Android 앱 개발과 Google Play 배포가 처음인 독자를 위한 실습 자료")
  )
  nav_path = config.fetch(:nav_path, "#{ANDROID_PUBLIC_ROOT}/")
  nav_label = config.fetch(:nav_label, "← Android 자료 첫 화면")
  <<~HTML
    <!doctype html>
    <html lang="ko">
      <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="description" content="#{escaped_description}" />
        <title>#{escaped_title} | My Food Archive</title>
        <style>
          :root {
            color-scheme: light;
            font-family: -apple-system, BlinkMacSystemFont, "Apple SD Gothic Neo", "Noto Sans KR", sans-serif;
            color: #202124;
            background: #f7f5f2;
          }
          * { box-sizing: border-box; }
          body { margin: 0; }
          nav { position: sticky; top: 0; z-index: 2; padding: 14px 20px; border-bottom: 1px solid #ded7cf; background: rgba(247, 245, 242, .96); backdrop-filter: blur(10px); }
          nav div { width: min(860px, 100%); margin: 0 auto; display: flex; gap: 18px; align-items: center; justify-content: space-between; }
          nav a { color: #5c3b25; font-weight: 700; text-decoration: none; }
          nav span { color: #6d655f; font-size: .9rem; text-align: right; }
          main { width: min(860px, calc(100% - 32px)); margin: 0 auto; padding: 38px 0 72px; }
          h1 { margin-top: 0; font-size: clamp(2rem, 6vw, 3rem); line-height: 1.2; }
          h2 { margin-top: 3.2rem; padding-top: .5rem; border-top: 1px solid #ded7cf; }
          h3 { margin-top: 2.2rem; }
          p, li { line-height: 1.8; }
          li + li { margin-top: .32rem; }
          a { color: #135f9b; text-underline-offset: 3px; }
          img { display: block; max-width: 100%; height: auto; margin: 24px auto; border: 1px solid #e3ded8; border-radius: 10px; background: #fff; }
          p[align="center"] > img[width="30%"] { display: inline-block; width: 30%; margin: 24px .7%; vertical-align: top; }
          table { display: block; width: 100%; overflow-x: auto; border-collapse: collapse; margin: 20px 0 28px; background: #fff; }
          th, td { min-width: 130px; padding: 12px 14px; border: 1px solid #ded7cf; text-align: left; vertical-align: top; line-height: 1.6; }
          th { background: #efe8e0; }
          pre { overflow-x: auto; padding: 18px; border-radius: 10px; background: #26221f; color: #fff; line-height: 1.6; }
          code { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace; }
          :not(pre) > code { padding: .15em .35em; border-radius: 5px; background: #eee8e2; }
          blockquote { margin: 22px 0; padding: 2px 18px; border-left: 4px solid #a97755; background: #f0e9e2; }
          hr { margin: 42px 0; border: 0; border-top: 1px solid #ded7cf; }
          @media (max-width: 640px) {
            nav span { display: none; }
            main { width: min(100% - 24px, 860px); padding-top: 26px; }
            th, td { min-width: 165px; }
            p[align="center"] > img[width="30%"] { display: block; width: min(100%, 320px); margin: 18px auto; }
          }
        </style>
      </head>
      <body>
        <nav><div><a href="#{nav_path}">#{nav_label}</a><span>#{escaped_title}</span></div></nav>
        <main>#{body}</main>
      </body>
    </html>
  HTML
end

PAGES.each do |source, config|
  markdown = strip_front_matter(source.read)
  body = Kramdown::Document.new(markdown, input: "GFM", hard_wrap: false).to_html
  body = rewrite_relative_urls(body, source)
  output_directory = OUTPUT_ROOT.join(config.fetch(:output))
  FileUtils.mkdir_p(output_directory)
  output_directory.join("index.html").write(page_template(config, body))
end

puts "Built #{PAGES.length} reader pages in #{OUTPUT_ROOT}"
