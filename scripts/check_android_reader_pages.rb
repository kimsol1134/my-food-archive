#!/usr/bin/env ruby

require "cgi"
require "pathname"
require "uri"

ROOT = Pathname.new(__dir__).join("..").expand_path
SITE_ROOT = Pathname.new(ENV.fetch("SITE_ROOT", ROOT.join("site", "android").to_s)).expand_path
PUBLIC_ROOT = "/my-food-archive/android"
RAW_ROOT = "https://raw.githubusercontent.com/kimsol1134/my-food-archive/main/"

errors = []
pages = SITE_ROOT.glob("**/index.html").sort
expected_pages = %w[
  app-screenshots
  internal-test
  overview
  privacy-policy
  release
  tester-recruitment
]

missing_pages = expected_pages.reject { |slug| SITE_ROOT.join(slug, "index.html").file? }
errors << "Missing generated pages: #{missing_pages.join(', ')}" unless missing_pages.empty?

def page_for_public_url(href)
  path, fragment = href.split("#", 2)
  relative = path.delete_prefix(PUBLIC_ROOT).sub(%r{\A/}, "")
  target = relative.empty? ? SITE_ROOT.join("index.html") : SITE_ROOT.join(relative, "index.html")
  [target.cleanpath, fragment]
end

pages.each do |page|
  html = page.read
  ids = html.scan(/\bid="([^"]+)"/).flatten.map { |id| CGI.unescapeHTML(id) }

  if html.match?(%r{https://github\.com/kimsol1134/my-food-archive})
    errors << "#{page.relative_path_from(ROOT)} links to the GitHub repository UI"
  end

  if html.match?(%r{(?<!href=")https://(?:support\.google\.com|developer\.android\.com|firebase\.google\.com|docs\.flutter\.dev)})
    errors << "#{page.relative_path_from(ROOT)} contains an official URL that is not clickable"
  end

  html.scan(/\bhref="([^"]+)"/).flatten.each do |encoded_href|
    href = CGI.unescapeHTML(encoded_href)
    next if href.empty? || href.start_with?("mailto:")
    next if href.match?(%r{\Ahttps?://})

    target, fragment = if href.start_with?("#")
                         [page, href.delete_prefix("#")]
                       elsif href.start_with?(PUBLIC_ROOT)
                         page_for_public_url(href)
                       elsif href.start_with?("./", "../")
                         path, local_fragment = href.split("#", 2)
                         candidate = page.dirname.join(path).cleanpath
                         candidate = candidate.join("index.html") if candidate.directory?
                         [candidate, local_fragment]
                       else
                         next
                       end

    unless target.file?
      errors << "#{page.relative_path_from(ROOT)} has missing link target: #{href}"
      next
    end

    next if fragment.nil? || fragment.empty?

    target_ids = target == page ? ids : target.read.scan(/\bid="([^"]+)"/).flatten.map { |id| CGI.unescapeHTML(id) }
    errors << "#{page.relative_path_from(ROOT)} has missing anchor: #{href}" unless target_ids.include?(fragment)
  end

  html.scan(/\bsrc="([^"]+)"/).flatten.each do |encoded_src|
    src = CGI.unescapeHTML(encoded_src)
    next unless src.start_with?(RAW_ROOT)

    relative = URI.decode_www_form_component(src.delete_prefix(RAW_ROOT))
    errors << "#{page.relative_path_from(ROOT)} has missing source image: #{relative}" unless ROOT.join(relative).file?
  end
end

if errors.empty?
  puts "Android reader check passed: #{pages.length} pages"
else
  warn errors.join("\n")
  exit 1
end
