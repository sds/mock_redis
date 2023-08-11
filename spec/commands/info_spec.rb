require 'spec_helper'

RSpec.describe '#info [mock only]' do
  let(:redis) { @redises.mock }

  it 'responds with a config hash' do
    expect(redis.info).to be_a(Hash)
  end

  it 'gets default set of info' do
    info = redis.info
    expect(info['arch_bits']).to be_a(String)
    expect(info['connected_clients']).to be_a(String)
    expect(info['aof_rewrite_scheduled']).to be_a(String)
    expect(info['used_cpu_sys']).to be_a(String)
  end

  it 'gets all info' do
    info = redis.info(:all)
    expect(info['arch_bits']).to be_a(String)
    expect(info['connected_clients']).to be_a(String)
    expect(info['aof_rewrite_scheduled']).to be_a(String)
    expect(info['used_cpu_sys']).to be_a(String)
    expect(info['cmdstat_slowlog']).to be_a(String)
  end

  it 'gets server info' do
    expect(redis.info(:server)['arch_bits']).to be_a(String)
  end

  it 'gets clients info' do
    expect(redis.info(:clients)['connected_clients']).to be_a(String)
  end

  it 'gets memory info' do
    expect(redis.info(:memory)['used_memory']).to be_a(String)
  end

  it 'gets persistence info' do
    expect(redis.info(:persistence)['aof_rewrite_scheduled']).to be_a(String)
  end

  it 'gets stats info' do
    expect(redis.info(:stats)['keyspace_hits']).to be_a(String)
  end

  it 'gets replication info' do
    expect(redis.info(:replication)['role']).to be_a(String)
  end

  it 'gets cpu info' do
    expect(redis.info(:cpu)['used_cpu_sys']).to be_a(String)
  end

  it 'gets keyspace info' do
    expect(redis.info(:keyspace)['db0']).to be_a(String)
  end

  it 'gets commandstats info' do
    expect(redis.info(:commandstats)['sunionstore']['usec']).to be_a(String)
  end
end
