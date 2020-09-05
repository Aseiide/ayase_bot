require 'rspec/autorun'

def fizz_buzz(args)
  if args % 15 == 0
    "fizzbuzz"
  elsif args % 3 == 0
    "fizz"
  elsif args % 5 == 0
    "5で割れるよ"
  else
    args
  end
end

describe "#fizz_buzz" do
  let(:fizz_3) { fizz_buzz(3) }
  let(:fizz_5) { fizz_buzz(5) }

  it "fizzを出力すること" do
    # fizz_3 = fizz_buzz(3)
    expect(fizz_3).to eq("fizz")
  end

  it "buzzを出力すること" do
    expect(fizz_5).to eq("buzz")
  end
end

