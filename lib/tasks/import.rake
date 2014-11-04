namespace :import do
  desc "(Re-)Imports the typo3 categories"
  task :typo3 => :environment do
    LegacyCategory.import_all
  end
end