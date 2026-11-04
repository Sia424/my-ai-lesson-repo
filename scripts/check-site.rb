#!/usr/bin/env ruby
# Static publishing checks. Pass --built to also inspect Jekyll output.
require "yaml"
require "uri"
require "pathname"

root = File.expand_path("..", __dir__)
Dir.chdir(root)
config = YAML.load_file("_config.yml")
errors = []
pages = {}
link_count = 0
Dir.glob("**/*.md").reject { |p| p.start_with?("_site/", "vendor/", "node_modules/") }.each do |file|
  body = File.read(file)
  if body.start_with?("---\n")
    errors << "Published Markdown filenames must not contain spaces: #{file}" if file.include?(" ")
    front = body.split(/^---\s*$\n?/, 3)[1]
    data = YAML.safe_load(front)
    path = data && data["permalink"]
    if path
      errors << "Duplicate page URL: #{path}" if pages.value?(path)
      pages[file] = path
    end
  end
  errors << "Unpaired code fences: #{file}" if body.scan(/^```/).size.odd?
  body.scan(/\]\(([^)]+)\)/).flatten.each do |target|
    next if target.match?(/\A(?:[a-z][a-z0-9+.-]*:|#)/i)
    link_count += 1
    decoded = URI::DEFAULT_PARSER.unescape(target.split("#").first)
    local = File.expand_path(decoded, File.dirname(File.expand_path(file)))
    errors << "Missing link: #{file} -> #{target}" unless File.exist?(local)
  end
end

expected_urls = %w[/ /chapters/ /introduction/ /safety/ /github-setup/ /license/]
errors << "Unexpected public pages" unless pages.values.sort == expected_urls.sort
errors << "Unexpected project URL" unless config["baseurl"] == "/my-ai-lesson-repo"
errors << "Wrong repository" unless config["repository"] == "Sia424/my-ai-lesson-repo"
errors << "Missing link conversion plugin" unless config.fetch("plugins", []).include?("jekyll-relative-links")
private_paths = %w[README.md AGENTS.md CLAUDE.md ROADMAP.md PUBLISH_PLAN.md LICENSE Gemfile scripts guides examples assets/README.md .tmp vendor node_modules]
private_paths.each do |path|
  errors << "Missing website exclusion: #{path}" unless config.fetch("exclude", []).include?(path)
end
layout = File.read("_layouts/default.html")
%w[<html <head> <main <nav <footer].each do |tag|
  errors << "Missing layout structure: #{tag}" unless layout.include?(tag)
end
expected_urls.each do |url|
  errors << "Missing sidebar link: #{url}" unless layout.include?("'#{url}'")
end
errors << "Missing mobile viewport" unless layout.include?('name="viewport"')
errors << "Missing responsive styles" unless File.read("assets/site/style.css").include?("@media(max-width:")

if ARGV.include?("--built")
  errors << "No Jekyll build found" unless File.directory?("_site")
  expected_files = expected_urls.map { |p| "#{p.sub(%r{^/}, '')}index.html" } + ["assets/site/style.css"]
  actual_files = Dir.glob("_site/**/*").select { |p| File.file?(p) }.map { |p| p.sub("_site/", "") }
  # GitHub's native builder can add its default theme stylesheet.
  allowed_files = expected_files + ["assets/css/style.css"]
  file_errors = (actual_files - allowed_files) + (expected_files - actual_files)
  errors << "Unexpected or missing build files: #{file_errors}" unless file_errors.empty?
  actual_files.grep(/\.html$/).each do |file|
    html = File.read("_site/#{file}")
    errors << "Unrendered Liquid: #{file}" if html.match?(/\{[{%]/)
    html.scan(/(?:href|src)="([^"]+)"/).flatten.each do |href|
      next if href.match?(/\A(?:[a-z][a-z0-9+.-]*:|#|\/\/)/i)
      path = URI::DEFAULT_PARSER.unescape(href.split(/[?#]/).first)
      if path.start_with?("/")
        prefix = config.fetch("baseurl") + "/"
        unless path.start_with?(prefix)
          errors << "Missing baseurl: #{file} -> #{href}"
          next
        end
        target = File.join("_site", path.delete_prefix(prefix))
      else
        target = File.expand_path(path, File.dirname(File.expand_path("_site/#{file}")))
      end
      target = File.join(target, "index.html") if File.directory?(target)
      errors << "Broken output link: #{file} -> #{href}" unless File.file?(target)
    end
  end
end

puts "Checked #{link_count} Markdown links and #{pages.size} configured pages."
if errors.empty?
  puts ARGV.include?("--built") ? "Static and generated-site checks passed." : "Static checks passed. Jekyll build and visual rendering are not verified."
else
  warn errors.join("\n")
  exit 1
end
