require 'helpers'

describe VK::IRB::Params do
  let(:argv)        { [] }
  let(:docopt)      { Docopt::docopt(VK::IRB::Params::DOCOPT, { argv: argv }) }
  let(:params)      { VK::IRB::Params.new(docopt) }
  let(:name)        { 'name' }
  let(:token)       { 'token' }
  let(:file)        { 'file' }
  let(:pwd_vk_yml)  { "#{ ENV['PWD'] }/.vk.yml" }
  let(:user_vk_yml) { "#{ ENV['HOME'] }/.vk.yml" }

  describe 'commands' do
    describe 'list' do
      let(:argv) { ['list'] }

      it { params.list?.should be_true }
      it { params.add?.should be_false }
      it { params.remove?.should be_false }
      it { params.update?.should be_false }
      it { params.eval?.should be_false }
      it { params.execute?.should be_false }
      it { params.user_name.should be_false }
      it { params.token.should be_nil }
      it { params.evaluated_code.should be_nil }
      it { params.executed_file.should be_nil }
    end

    describe 'add' do
      context 'without token' do
        let(:argv) { ['add', name] }

        it { params.list?.should be_false }
        it { params.add?.should be_true }
        it { params.remove?.should be_false }
        it { params.update?.should be_false }
        it { params.eval?.should be_false }
        it { params.execute?.should be_false }
        it { params.user_name.should eq(name) }
        it { params.token.should be_nil }
        it { params.evaluated_code.should be_nil }
        it { params.executed_file.should be_nil }
      end

      context 'with token' do
        let(:argv)  { ['add', name, token] }

        it { params.list?.should be_false }
        it { params.add?.should be_true }
        it { params.remove?.should be_false }
        it { params.update?.should be_false }
        it { params.eval?.should be_false }
        it { params.execute?.should be_false }
        it { params.user_name.should eq(name) }
        it { params.token.should eq(token) }
        it { params.evaluated_code.should be_nil }
        it { params.executed_file.should be_nil }
      end
    end

    describe 'update' do
      context 'without token' do
        let(:argv) { ['update', name] }

        it { params.list?.should be_false }
        it { params.add?.should be_false }
        it { params.remove?.should be_false }
        it { params.update?.should be_true }
        it { params.eval?.should be_false }
        it { params.execute?.should be_false }
        it { params.user_name.should eq(name) }
        it { params.token.should be_nil }
        it { params.evaluated_code.should be_nil }
        it { params.executed_file.should be_nil }
      end

      context 'with token' do
        let(:token) { 'token' }
        let(:argv)  { ['update', name, token] }

        it { params.list?.should be_false }
        it { params.add?.should be_false }
        it { params.remove?.should be_false }
        it { params.update?.should be_true }
        it { params.eval?.should be_false }
        it { params.execute?.should be_false }
        it { params.user_name.should eq(name) }
        it { params.token.should eq(token) }
        it { params.evaluated_code.should be_nil }
        it { params.executed_file.should be_nil }
      end
    end

    describe 'remove' do
      let(:argv) { ['remove', name] }

      it { params.list?.should be_false }
      it { params.add?.should be_false }
      it { params.remove?.should be_true }
      it { params.update?.should be_false }
      it { params.eval?.should be_false }
      it { params.execute?.should be_false }
      it { params.user_name.should eq(name) }
      it { params.token.should be_nil }
      it { params.evaluated_code.should be_nil }
      it { params.executed_file.should be_nil }
    end
  end

  context 'session' do
    let(:argv) { [name] }

    it { params.list?.should be_false }
    it { params.add?.should be_false }
    it { params.remove?.should be_false }
    it { params.update?.should be_false }
    it { params.eval?.should be_false }
    it { params.execute?.should be_false }
    it { params.user_name.should eq(name) }
    it { params.token.should be_nil }
    it { params.evaluated_code.should be_nil }
    it { params.executed_file.should be_nil }
  end

  describe 'options' do
    describe '--eval' do
      let(:evaluated_code) { 'ruby evaluated_code' }
      let(:argv)           { [name, "--eval=#{ evaluated_code }"] }

      it { params.list?.should be_false }
      it { params.add?.should be_false }
      it { params.remove?.should be_false }
      it { params.update?.should be_false }
      it { params.eval?.should be_true }
      it { params.execute?.should be_false }
      it { params.user_name.should eq(name) }
      it { params.token.should be_nil }
      it { params.evaluated_code.should eq(evaluated_code) }
      it { params.executed_file.should be_nil }
    end

    describe '--execute' do
      let(:argv) { [name, "--execute=#{ file }"] }

      it { params.list?.should be_false }
      it { params.add?.should be_false }
      it { params.remove?.should be_false }
      it { params.update?.should be_false }
      it { params.eval?.should be_false }
      it { params.execute?.should be_true }
      it { params.user_name.should eq(name) }
      it { params.token.should be_nil }
      it { params.evaluated_code.should be_nil }
      it { params.executed_file.should eq(file) }
    end

    describe '--config' do
      context 'with options' do
        let(:argv) { [name, "--config=#{ file }"] }

        before { File.stub(:exists?).with(pwd_vk_yml).and_return(false) }
        before { File.stub(:exists?).with(user_vk_yml).and_return(false) }
        before { File.stub(:exists?).with(file).and_return(true) }

        it { params.list?.should be_false }
        it { params.add?.should be_false }
        it { params.remove?.should be_false }
        it { params.update?.should be_false }
        it { params.eval?.should be_false }
        it { params.execute?.should be_false }
        it { params.user_name.should eq(name) }
        it { params.token.should be_nil }
        it { params.evaluated_code.should be_nil }
        it { params.executed_file.should be_nil }
        it { params.config_file.should eq(file) }
      end

      context 'without options' do
        let(:argv) { [name] }

        context 'with config in current dirrectory' do
          before { File.stub(:exists?).with(user_vk_yml).and_return(false) }
          before { File.stub(:exists?).with(pwd_vk_yml).and_return(true) }

          it { params.list?.should be_false }
          it { params.add?.should be_false }
          it { params.remove?.should be_false }
          it { params.update?.should be_false }
          it { params.eval?.should be_false }
          it { params.execute?.should be_false }
          it { params.user_name.should eq(name) }
          it { params.token.should be_nil }
          it { params.evaluated_code.should be_nil }
          it { params.executed_file.should be_nil }
          it { params.config_file.should eq(pwd_vk_yml) }
        end

        context 'without config in current dirrectory' do
          before { File.stub(:exists?).with(pwd_vk_yml).and_return(false) }

          context 'with config in user home dirrectory' do
            before { File.stub(:exists?).with(user_vk_yml).and_return(true) }

            it { params.list?.should be_false }
            it { params.add?.should be_false }
            it { params.remove?.should be_false }
            it { params.update?.should be_false }
            it { params.eval?.should be_false }
            it { params.execute?.should be_false }
            it { params.user_name.should eq(name) }
            it { params.token.should be_nil }
            it { params.evaluated_code.should be_nil }
            it { params.executed_file.should be_nil }
            it { params.config_file.should eq(user_vk_yml) }
          end

          context 'without config in user home dirrectory' do
            before { File.stub(:exists?).with(user_vk_yml).and_return(false) }

            it { params.list?.should be_false }
            it { params.add?.should be_false }
            it { params.remove?.should be_false }
            it { params.update?.should be_false }
            it { params.eval?.should be_false }
            it { params.execute?.should be_false }
            it { params.user_name.should eq(name) }
            it { params.token.should be_nil }
            it { params.evaluated_code.should be_nil }
            it { params.executed_file.should be_nil }
            it { params.config_file.should eq VK::IRB::Params::DEFAULT_CONFIG_FILE }
          end
        end
      end

    end

  end
end