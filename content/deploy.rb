require "json"
require "yaml"
require "fileutils"

content = File.dirname(__FILE__)
destination = File.join File.dirname(content), "client", "public", "api", "lessons"
FileUtils.mkdir_p destination

Dir.glob File.join(content, "_data", "*.yaml") do |path|
  slug = File.basename(path, ".yaml")
  config = YAML.load_file(path)
  File.write File.join(destination, slug), JSON.generate(
    title: config["title"],
    items: config["items"].map do |item|
      markdown = File.join(content, slug, "#{item}.md")
      YAML.load_file(markdown).tap do |data|
        data["content"] = File.read(markdown).split("---")[2..-1].join.strip
      end
    end
  )
end
