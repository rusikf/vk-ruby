require 'helpers'

describe VK::Application, type: :application do

  it {
    each_namespace { |namespace_name|
      subject.send(namespace_name).tap { |object|
        object.should be_a(VK::Methods)
        object.send(:namespace).should eq(namespace_name)
      }
    }
  }

  context 'GET method' do
    let(:verb) { :get }

    before { stubs_get! }

    it {
      each_methods { |method_name, params|
        expect{ eval("subject.#{ method_name }(params)") }.to_not raise_error
      }
    }

    it {
      each_methods { |method_name, params|
        eval("subject.#{ method_name }(params)").should eq(params.stringify)
      }
    }
  end

  context 'POST method' do
    let(:verb) { :post }

    before { stubs_post! }

    it {
      each_methods { |method_name, params|
        expect{ eval("subject.#{ method_name }(params)") }.to_not raise_error
      }
    }

    it {
      each_methods { |method_name, params|
        eval("subject.#{ method_name }(params)").should eq(params.stringify)
      }
    }
  end

end