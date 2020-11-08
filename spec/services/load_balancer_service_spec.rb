# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadBalancerService do
  let(:service) { LoadBalancerService.new }

  context 'no providers' do
    it 'raises an exception' do
      expect { service.process }.to raise_error(LoadBalancerService::NoAvailableProviders)
    end
  end

  context '2 providers' do
    before do
      @provider1 = FactoryBot.create(:provider, weight: 30.0)
      @provider2 = FactoryBot.create(:provider, weight: 70.0)
    end

    it 'load 0/0 - gotta start somewhere' do
      expect(service.process).to eq(@provider1.id)
    end

    it 'load 1/0' do
      FactoryBot.create(:notification, :queued, provider: @provider1)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 1/1' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 2/1' do
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 3/1' do
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 1/2' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 1/3' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider1.id)
    end

    it 'load 3/7' do
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 7, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider1.id)
    end

    it 'load 3/8' do
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 8, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider1.id)
    end

    it 'load 4/7' do
      FactoryBot.create_list(:notification, 4, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 7, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end
  end

  context '3 providers' do
    before do
      @provider1 = FactoryBot.create(:provider, weight: 20.0)
      @provider2 = FactoryBot.create(:provider, weight: 30.0)
      @provider3 = FactoryBot.create(:provider, weight: 50.0)
    end

    it 'load 0/0/0 - gotta start somewhere' do
      expect(service.process).to eq(@provider1.id)
    end

    it 'load 1/0/0' do
      FactoryBot.create(:notification, :queued, provider: @provider1)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 1/1/1' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)
      FactoryBot.create(:notification, :queued, provider: @provider3)

      expect(LoadBalancerService.process).to eq(@provider3.id)
    end

    it 'load 2/1/0' do
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider3.id)
    end

    it 'load 3/1/0' do
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider1)
      FactoryBot.create(:notification, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end

    it 'load 1/2/0' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider3.id)
    end

    it 'load 1/3/0' do
      FactoryBot.create(:notification, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider2)

      expect(LoadBalancerService.process).to eq(@provider3.id)
    end

    it 'load 2/3/5' do
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider2)
      FactoryBot.create_list(:notification, 5, :queued, provider: @provider3)

      expect(LoadBalancerService.process).to eq(@provider1.id)
    end

    it 'load 2/4/5' do
      FactoryBot.create_list(:notification, 2, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 4, :queued, provider: @provider2)
      FactoryBot.create_list(:notification, 5, :queued, provider: @provider3)

      expect(LoadBalancerService.process).to eq(@provider1.id)
    end

    it 'load 3/3/5' do
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider1)
      FactoryBot.create_list(:notification, 3, :queued, provider: @provider2)
      FactoryBot.create_list(:notification, 5, :queued, provider: @provider3)

      expect(LoadBalancerService.process).to eq(@provider2.id)
    end
  end
end
