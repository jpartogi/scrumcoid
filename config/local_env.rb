module LocalEnv
  module_function

  def load(*paths)
    paths.each do |path|
      next unless File.file?(path)

      File.foreach(path) do |line|
        key, value = parse_line(line)
        ENV[key] ||= value if key
      end
    end
  end

  def parse_line(line)
    line = line.strip
    line = line.delete_prefix("export ").strip
    return if line.blank? || line.start_with?("#")

    key, value = line.split("=", 2)
    return if key.blank? || value.nil?

    [ key.strip, unquote(value.strip) ]
  end

  def unquote(value)
    quote = value[0]
    return value[1...-1] if %w[" '].include?(quote) && value.end_with?(quote)

    value.split(/\s+#/, 2).first.to_s.strip
  end
end
