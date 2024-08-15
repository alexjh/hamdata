require 'fileutils'

module Hamdata
  extend self

  def open_output_file(path)
    output_dir = File.join(site_dir, File.dirname(path))
    FileUtils.mkdir_p(output_dir)
    output_file = File.join(output_dir, File.basename(path))

    File.open(output_file, 'w') do |f|
      yield f
    end
  end

  def site_dir
    File.join(File.dirname(__FILE__), '..', '_site')
  end

  def clear_site_dir
    FileUtils.rm_rf(site_dir)
  end

  def generate(feed_dir)
    require_relative "../#{feed_dir}/generate"
  end

  def read_config(feed_dir)
    JSON.parse(File.read(File.join(File.dirname(__FILE__), "../#{feed_dir}/feed.json")))
  end

  def generate_index(configs)
    index_html = File.read(File.join(File.dirname(__FILE__), '..', 'assets', 'index.html'))

    content = configs.map do |config|
      files_li = config['files'].map do |file|
        file_size_kb = File.size(File.join(Hamdata.site_dir, file['path'])) / 1024
    
        """
        <li>
          <a href=\"#{file['path']}\">#{file['path']}</a> (#{file_size_kb} kb)<br />
          #{file['description']}
        </li>
        """
      end.join("\n")
    
      <<-HTML
        <section>
          <h2>#{config['title']}</h2>
          <ul>#{files_li}</ul>
        </section>
      HTML
    end.join("\n")
    
    index_html.gsub!('<!-- CONTENT -->', content)
    index_html.gsub!('<!-- NOW -->', Time.now.utc.to_s)
    
    File.write(File.join(Hamdata.site_dir, 'index.html'), index_html)
  end
end