def shell_paths
  case fact('osfamily')
  when 'Debian'
    [
      '/etc/profile.d/lmod.sh',
      '/etc/csh/login.d/lmod.csh',
    ]
  else
    [
      '/etc/profile.d/modules.sh',
      '/etc/profile.d/modules.csh',
    ]
  end
end

shared_examples_for 'lmod::load' do
  shell_paths.each do |file|
    describe file(file) do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 644 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end
  end
end
