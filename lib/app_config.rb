class AppConfig
  def self.get(key)
    config = YAML.load(
      File.open(Rails.root.join('config', 'app_configs.yml')),
      aliases: true
    )[Rails.env]
    config[key.to_s]
  end
end
