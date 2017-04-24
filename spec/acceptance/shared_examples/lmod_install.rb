def base_packages
  case fact('osfamily')
  when 'RedHat'
    if fact('operatingsystemmajrelease') == '5'
      [
        'lua-filesystem',
        'lua-posix',
        'tcl',
        'zsh',
      ]
    else
      [
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'tcl',
        'zsh',
      ]
    end
  when 'Debian'
    if fact('operatingsystemmajrelease') == '14.04'
      [
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'tcl',
        'tcsh',
        'zsh',
      ]
    else
      [
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'tcl',
        'tcsh',
        'zsh',
      ]
    end
  else
    []
  end
end

def runtime_packages
  case fact('osfamily')
  when 'RedHat'
    [
      'lua',
    ]
  when 'Debian'
    [
      'lua5.2'
    ]
  else
    []
  end
end

def build_packages
  case fact('osfamily')
  when 'RedHat'
    [
      'lua-devel',
    ]
  when 'Debian'
    [
      'liblua5.2-dev',
      'lua-filesystem-dev',
      'lua-posix-dev'
    ]
  else
    []
  end
end

shared_examples_for 'lmod::install without build packages' do
  base_packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

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
  base_packages.each do |package|
    describe package(package) do
      it { should be_installed }
    end
  end

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
