Pod::Spec.new do |spec|
  spec.name = "KKDSqlite"
  spec.version = "1.0.0"
  spec.summary = "Sqlite Helper Library for Objective C"
  spec.homepage = "https://github.com/KadirKemal/KKDSqlite"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Kadir Kemal Dursun" => 'kkdursun@yahoo.com' }
  spec.social_media_url = "https://twitter.com/Kadir_Kemal"

  spec.platform = :ios, "8.0"
  spec.requires_arc = true
  spec.source = { git: "https://github.com/KadirKemal/KKDSqlite.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "KKDSqlite/*.{h,m}"
end
