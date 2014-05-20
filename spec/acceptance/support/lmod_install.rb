def runtime_packages
  [
    'lua',
    'lua-filesystem',
    'lua-posix',
    'zsh',
  ]
end

def build_packages
  [
    'lua-devel',
  ]
end

shared_examples_for 'lmod::install without build packages' do
  runtime_packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  build_packages.each do |package|
    describe package(package) do
      it { should_not be_installed }
    end
  end
end

shared_examples_for 'lmod::install with build packages' do
  runtime_packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

  build_packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end
end
