defmodule Hexxeh do

  # empty clause to solve the following
  # warning: definitions with multiple clauses and default values require a function head. Instead of:
  def find_next(string, count \\ 0)

  def find_next(_, 50) do
    "Not found"
  end

  def find_next(string, count) do
    string
    |> parse
    |> check
    |> case do
      {"", _} -> "Invalid"
      {result, true} -> result
      {result, false} -> find_next(result, count + 1)
    end
  end


  def check(arg) when is_integer(arg) do
    arg + 1 |> Integer.to_string(16) |> check_palindrome
  end

  def check(_), do: {"", false}

  def parse(string) do
    string
    |> Integer.parse(16)
    |> case do
      {int, _} -> int
    end
  end

  def check_palindrome(str) do
    {str, str == String.reverse(str)}
  end
end
