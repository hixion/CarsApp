defmodule CarsAppWeb.PageController do
  alias CarsApp.Cars
  use CarsAppWeb, :controller

  action_fallback CarsAppWeb.FallbackController

  def status(conn, _params) do
    # I'll get the status of the redis connection by using a GET command
    case Redix.command(:redix, ["GET", "val"]) do
      {:error, %Redix.ConnectionError{reason: :closed}} ->
        {:error, :connection_closed}

      {:error, _} ->
        {:error, :unknown_error}

      {:ok, _} ->
        send_resp(conn, 200, "200 OK")
    end
  end

  @doc """
    We'll receive a json with a list of cars and we are going to store them.

    When the format is correct we will respond with a 200 OK
    Otherwise we'll response with a 400 Bad Request
  """
  def cars(conn, %{"_json" => json_data}) do
    is_json_format_valid? = check_format_json(json_data)

    with {:ok, :valid} <- is_json_format_valid? do
      {:ok, _} = Cars.store_cars(json_data)
      send_resp(conn, 200, "200 OK")
    end
  end

  def cars(_, _), do: {:error, :bad_request}

  def journey(conn, %{"_json" => _json_data}) do
    # TODO: Store group of people from json_data
    send_resp(conn, 200, "")
  end

  def journey(_, _), do: {:error, :bad_request}

  def dropoff(conn, %{"ID" => _id}) do
    # TODO
    send_resp(conn, 200, "")
  end

  def dropoff(_, _), do: {:error, :bad_request}

  def locate(conn, %{"ID" => _id}) do
    # TODO
    send_resp(conn, 200, "")
  end

  def locate(_, _), do: {:error, :bad_request}

  defp check_format_json(json_data) when is_list(json_data) do
    is_format_valid? =
      Enum.reduce(json_data, true, fn car_map, acc ->
        acc and Cars.is_car_format_valid?(car_map)
      end)

    if is_format_valid?, do: {:ok, :valid}, else: {:error, :bad_request}
  end

  defp check_format_json(_), do: {:error, :bad_request}
end
