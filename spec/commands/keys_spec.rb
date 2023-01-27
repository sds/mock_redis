require 'spec_helper'

RSpec.describe '#keys()' do
  it 'returns [] when no keys are found (no regex characters)' do
    expect(@redises.keys('mock-redis-test:29016')).to eq([])
  end

  it 'returns [] when no keys are found (some regex characters)' do
    expect(@redises.keys('mock-redis-test:29016*')).to eq([])
  end

  describe 'with pattern matching' do
    before do
      @redises.set('mock-redis-test:key',   0)
      @redises.set('mock-redis-test:key1',  1)
      @redises.set('mock-redis-test:key2',  2)
      @redises.set('mock-redis-test:key3',  3)
      @redises.set('mock-redis-test:key10', 10)
      @redises.set('mock-redis-test:key20', 20)
      @redises.set('mock-redis-test:key30', 30)

      @redises.set('mock-redis-test:regexp-key(1|22)', 40)
      @redises.set('mock-redis-test:regexp-key3+', 40)
      @redises.set('mock-redis-test:regexp-key33', 40)
      @redises.set('mock-redis-test:regexp-key4a', 40)
      @redises.set('mock-redis-test:regexp-key4-', 40)
      @redises.set('mock-redis-test:regexp-key4b', 40)
      @redises.set('mock-redis-test:regexp-key4c', 40)

      @redises.set('mock-redis-test:special-key?', 'true')
      @redises.set('mock-redis-test:special-key*', 'true')
      @redises.set('mock-redis-test:special-key-!?*', 'true')
    end

    describe 'the ? character' do
      it 'is treated as a single character (at the end of the pattern)' do
        expect(@redises.keys('mock-redis-test:key?').sort).to eq([
          'mock-redis-test:key1',
          'mock-redis-test:key2',
          'mock-redis-test:key3',
        ])
      end

      it 'is treated as a single character (in the middle of the pattern)' do
        expect(@redises.keys('mock-redis-test:key?0').sort).to eq([
          'mock-redis-test:key10',
          'mock-redis-test:key20',
          'mock-redis-test:key30',
        ])
      end

      it 'treats \\? as a literal ?' do
        expect(@redises.keys('mock-redis-test:special-key\?').sort).to eq([
          'mock-redis-test:special-key?',
        ])
      end

      context 'multiple ? characters' do
        it "properly handles multiple consequtive '?' characters" do
          expect(@redises.keys('mock-redis-test:special-key-???').sort).to eq([
            'mock-redis-test:special-key-!?*',
          ])
        end

        context '\\? as a literal ' do
          it 'handles multiple ? as both literal and special character' do
            expect(@redises.keys('mock-redis-test:special-key-?\??').sort).to eq([
              'mock-redis-test:special-key-!?*',
            ])
          end
        end
      end
    end

    describe 'the * character' do
      it 'is treated as 0 or more characters' do
        expect(@redises.keys('mock-redis-test:key*').sort).to eq([
          'mock-redis-test:key',
          'mock-redis-test:key1',
          'mock-redis-test:key10',
          'mock-redis-test:key2',
          'mock-redis-test:key20',
          'mock-redis-test:key3',
          'mock-redis-test:key30',
        ])
      end

      it 'treats \\* as a literal *' do
        expect(@redises.keys('mock-redis-test:special-key\*').sort).to eq([
          'mock-redis-test:special-key*',
        ])
      end
    end

    describe 'character classes ([abcde])' do
      it 'matches any one of those characters' do
        expect(@redises.keys('mock-redis-test:key[12]').sort).to eq([
          'mock-redis-test:key1',
          'mock-redis-test:key2',
        ])
      end
    end

    describe 'the | character' do
      it "is treated as literal (not 'or')" do
        expect(@redises.keys('mock-redis-test:regexp-key(1|22)').sort).to eq([
          'mock-redis-test:regexp-key(1|22)',
        ])
      end
    end

    describe 'the + character' do
      it "is treated as literal (not 'one or more' quantifier)" do
        expect(@redises.keys('mock-redis-test:regexp-key3+').sort).to eq([
          'mock-redis-test:regexp-key3+',
        ])
      end
    end

    describe 'character classes ([a-c])' do
      it 'specifies a range which matches any lowercase letter from "a" to "c"' do
        expect(@redises.keys('mock-redis-test:regexp-key4[a-c]').sort).to eq([
          'mock-redis-test:regexp-key4a',
          'mock-redis-test:regexp-key4b',
          'mock-redis-test:regexp-key4c',
        ])
      end
    end

    describe 'combining metacharacters' do
      it 'works with different metacharacters simultaneously' do
        expect(@redises.keys('mock-redis-test:k*[12]?').sort).to eq([
          'mock-redis-test:key10',
          'mock-redis-test:key20',
        ])
      end
    end
  end
end
