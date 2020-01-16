defmodule Outer do
  defmodule Sample do
    def foo(), do: "hey"
  end

  defmodule Fizz do
    def buzz(), do: "okay"
  end
end

defmodule Dude do
  alias Outer.Sample
  alias Outer.Fizz

  def what() do
    Outer.Sample.foo()
    Sample.foo()
  end

  def whoa() do
    Outer.Fizz.buzz()
  end
end
