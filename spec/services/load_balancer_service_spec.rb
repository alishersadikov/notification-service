# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LoadBalancerService do
  let(:service) { LoadBalancerService.new }
  context 'suggests the right provider' do
    it 'load 0/0 - gotta start somewhere' do
      expect(service.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 1/0' do
      FactoryBot.create(:notification, :provider1, :queued)

      expect(service.provider_1_load).to eq 1
      expect(service.provider_2_load).to eq 0
      expect(service.actual_ratio).to eq(30.0 / 70)
      expect(service.target_ratio).to eq(30.0 / 70)
      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 1/1' do
      FactoryBot.create(:notification, :provider1, :queued)
      FactoryBot.create(:notification, :provider2, :queued)

      expect(service.provider_1_load).to eq 1
      expect(service.provider_2_load).to eq 1
      expect(service.actual_ratio).to eq(1.0)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 2/1' do
      FactoryBot.create_list(:notification, 2, :provider1, :queued)
      FactoryBot.create(:notification, :provider2, :queued)

      expect(service.provider_1_load).to eq 2
      expect(service.provider_2_load).to eq 1
      expect(service.actual_ratio).to eq(2.0)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 3/1' do
      FactoryBot.create_list(:notification, 3, :provider1, :queued)
      FactoryBot.create(:notification, :provider2, :queued)

      expect(service.provider_1_load).to eq 3
      expect(service.provider_2_load).to eq 1
      expect(service.actual_ratio).to eq(3.0)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 1/2' do
      FactoryBot.create(:notification, :provider1, :queued)
      FactoryBot.create_list(:notification, 2, :provider2, :queued)

      expect(service.provider_1_load).to eq 1
      expect(service.provider_2_load).to eq 2
      expect(service.actual_ratio).to eq(0.5)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 1/3' do
      FactoryBot.create(:notification, :provider1, :queued)
      FactoryBot.create_list(:notification, 3, :provider2, :queued)

      expect(service.provider_1_load).to eq 1
      expect(service.provider_2_load).to eq 3
      expect(service.actual_ratio).to eq(1.0 / 3)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_1_URL'])
    end

    it 'load 3/7' do
      FactoryBot.create_list(:notification, 3, :provider1, :queued)
      FactoryBot.create_list(:notification, 7, :provider2, :queued)

      expect(service.provider_1_load).to eq 3
      expect(service.provider_2_load).to eq 7
      expect(service.actual_ratio).to eq(3.0 / 7)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end

    it 'load 3/8' do
      FactoryBot.create_list(:notification, 3, :provider1, :queued)
      FactoryBot.create_list(:notification, 8, :provider2, :queued)

      expect(service.provider_1_load).to eq 3
      expect(service.provider_2_load).to eq 8
      expect(service.actual_ratio).to eq(3.0 / 8)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_1_URL'])
    end

    it 'load 4/7' do
      FactoryBot.create_list(:notification, 4, :provider1, :queued)
      FactoryBot.create_list(:notification, 7, :provider2, :queued)

      expect(service.provider_1_load).to eq 4
      expect(service.provider_2_load).to eq 7
      expect(service.actual_ratio).to eq(4.0 / 7)
      expect(service.target_ratio).to eq(30.0 / 70)

      expect(LoadBalancerService.process).to eq(ENV['PROVIDER_2_URL'])
    end
  end
end
