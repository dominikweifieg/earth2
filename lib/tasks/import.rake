namespace :import do
  desc "(Re-)Imports the typo3 categories"
  task :typo3 => :environment do
    LegacyCategory.import_all
  end
  desc "(Re-)Imports the kquest categories"
  task :kquest_categories => :environment do
    KquestCategory.import_all
  end
  desc "(Re-)Imports the kquest sets"
  task :kquest_sets => :environment do
    KquestQuestionSet.import_all
  end
end
