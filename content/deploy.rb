#!/usr/bin/env ruby

require "json"
require "yaml"

def content_data(path)
  YAML.load_file(path).tap do |data|
    data["content"] = File.read(path).split("---")[2..-1].join.strip
  end
end

content = File.dirname __FILE__
api = File.join content, "_api"
lessons = File.join api, "lessons"

YAML.load_file(File.join(content, "_data", "lessons.yaml")).each do |config|
  data = {
    title: config["title"],
    items: config["items"].map do |item|
      content_data File.join content, config["location"], "#{item}.md"
    end
  }
  File.write File.join(lessons, config["location"]), data.to_json
end

Dir.glob(File.join(content, "*.md")) do |path|
  destination = File.join api, File.basename(path, ".md")
  File.write destination, content_data(path).to_json
end
