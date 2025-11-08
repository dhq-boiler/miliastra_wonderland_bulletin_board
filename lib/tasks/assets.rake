# frozen_string_literal: true

# Tailwind CSSのビルドをassets:precompileに統合
namespace :assets do
  # assets:precompileの前にTailwind CSSをビルド
  task :precompile do
    if Rake::Task.task_defined?("tailwindcss:build")
      Rake::Task["tailwindcss:build"].invoke
    end
  end
end

# Tailwind CSSのビルドタスクが存在する場合、assets:precompile前に実行
if Rake::Task.task_defined?("assets:precompile")
  Rake::Task["assets:precompile"].enhance(["tailwindcss:build"]) if Rake::Task.task_defined?("tailwindcss:build")
end

