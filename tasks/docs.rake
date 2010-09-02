begin
  require 'yard'
  require 'haml'
  desc 'Build all documentation'
  task :docs => %w[docs:static docs:api]
  task :doc => :docs # alias for docs

  CLEAN.include 'docs/build'

  desc 'Build API documentation (docs/api)'
  task 'docs:api' => ['docs/build/.git'] do
    sh("yardoc -o docs/build/api -")
  end

  desc 'Build static documentation (docs)'
  task 'docs:static' => ['docs/build/.git'] do
    require 'pathname'
    require 'fileutils'
    require 'rubygems'
    require 'haml'

    module Highlighting
      def highlight(language, text)
        code = ""
        IO.popen("pygmentize -l#{language} -fhtml", "w+") do |io|
          io.write(text)
          io.close_write
          code = io.read
        end
        code
      end
    end

    module Haml::Filters::Code
      include Highlighting
      include Haml::Filters::Base
      def render(text)
        highlight('ruby', text)
      end
    end

    module Haml::Filters::Bash
      include Highlighting
      include Haml::Filters::Base
      def render(text)
        highlight('bash', text)
      end
    end

    class GeneratorContext
    end

    layout = Haml::Engine.new(File.read("docs/layout.html.haml"))

    FileList["docs/{stylesheets,images}/*"].each do |resource|
      path = Pathname(resource)
      relative_path = path.relative_path_from(Pathname("docs"))
      build_path = Pathname("docs/build") + relative_path
      FileUtils.mkdir_p(build_path.parent.to_s)
      FileUtils.copy(resource, build_path)
    end

    FileList["docs/**/*.haml"].exclude("docs/layout.html.haml").each do |entry|
      path = Pathname(entry)
      relative_path = path.relative_path_from(Pathname("docs"))
      build_path = Pathname("docs/build") + relative_path.parent + path.basename.sub(/\.haml$/, '')

      FileUtils.mkdir_p(build_path.dirname)

      File.open(build_path, "w") do |file|
        context = GeneratorContext.new
        content = ""

        Dir.chdir(path.dirname) do
          content = Haml::Engine.new(File.read(path.basename)).render(context)
        end

        puts "Writing: #{build_path.relative_path_from(Pathname("build"))}"
        file.write build_path.extname == ".html" ? layout.render(context, :content => content) : content
      end
    end
  end

  # GITHUB PAGES ===============================================================

  directory 'docs/build/'

  desc 'Update gh-pages branch'
  task :pages => ['docs/build/.git', :docs] do
    rev = `git rev-parse --short HEAD`.strip
    Dir.chdir 'docs/build' do
      sh "git add ."
      sh "git commit -m 'rebuild pages from #{rev}'" do |ok,res|
        if ok
          verbose { puts "gh-pages updated" }
          sh "git push -q o HEAD:gh-pages"
        end
      end
    end
  end

  # Update the pages/ directory clone
  file 'docs/build/.git' => ['docs/build/', '.git/refs/heads/gh-pages'] do |f|
    sh "cd docs/build && git init -q && git remote add o ../../.git" if !File.exist?(f.name)
    sh "cd docs/build && git fetch -q o && git reset -q --hard o/gh-pages && touch ."
  end
rescue LoadError
  warn "** Yard and Haml are required for generating documentation. Try: gem install yard haml **"
end
