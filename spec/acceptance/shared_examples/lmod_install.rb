def package_name
  if fact('osfamily') == 'RedHat'
    'Lmod'
  else
    'lmod'
  end
end

def runtime_packages
  case fact('osfamily')
  when 'RedHat'
    [
      'lua',
      'lua-filesystem',
      'lua-json',
      'lua-posix',
      'lua-term',
      'tcl',
      'zsh',
    ]
  when 'Debian'
    if fact('os.release.major') == '9'
      [
        'lua5.2',
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'tcl',
        'csh',
        'tcsh',
        'zsh',
      ]
    else
      [
        'lua5.3',
        'lua-filesystem',
        'lua-json',
        'lua-posix',
        'lua-term',
        'tcl8.6',
        'csh',
        'tcsh',
        'zsh',
      ]
    end
  else
    []
  end
end

def build_packages
  case fact('osfamily')
  when 'RedHat'
    [
      'gcc',
      'gcc-c++',
      'make',
      'tcl-devel',
      'lua-devel',
    ]
  when 'Debian'
    if fact('os.release.major') == '9'
      [
        'gcc',
        'g++',
        'make',
        'tcl-dev',
        'liblua5.2-dev',
        'lua-filesystem-dev',
        'lua-posix-dev',
      ]
    else
      [
        'gcc',
        'g++',
        'make',
        'tcl8.6-dev',
        'liblua5.3-dev',
        'lua-filesystem-dev',
        'lua-posix-dev',
      ]
    end
  else
    []
  end
end

shared_examples_for 'lmod::install package' do
  describe package(package_name) do
    it { is_expected.to be_installed }
  end
end

shared_examples_for 'lmod::install dependencies' do
  runtime_packages.each do |package|
    describe package(package) do
      it { is_expected.to be_installed }
    end
  end

  build_packages.each do |package|
    describe package(package) do
      it { is_expected.to be_installed }
    end
  end
end
