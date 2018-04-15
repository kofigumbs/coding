#!/usr/bin/env ruby

require "json"
require "yaml"
require "fileutils"

content = File.dirname(__FILE__)
destination = File.join File.dirname(content), "client", "public", "api", "lessons"
FileUtils.mkdir_p destination

YAML.load_file(File.join(content, "_data", "lessons.yaml")).each do |config|
  File.write File.join(destination, config["location"]), JSON.generate(
    title: config["title"],
    items: config["items"].map do |item|
      markdown = File.join content, config["location"], "#{item}.md"
      YAML.load_file(markdown).tap do |data|
        data["content"] = File.read(markdown).split("---")[2..-1].join.strip
      end
    end
  )
end
