# site.pp

node monitoring {
  include epel

  Yumrepo <| |> -> Package <| |>
}
