defmodule Db do
    # @dbcomment {
    #   id: 0,
    #   userid: 0,
    #   parentid: 0,
    #   content: "",
    #   like: 0,
    #   creation_timestamp: 0,
    # }
    # @dbuser {
    #   id: 0,
    #   userid: 0,
    #   parentid: 0,
    #   content: "",
    #   like: 0,
    #   creation_timestamp: 0,
    # }

  def get_string(maxlen,id) do
    num = id**3 + 69
    length = rem(num,maxlen)

    Enum.to_list(0..length)
    |> Enum.reduce(%{strlst: [], rand: num},fn _item, acc ->
        new_rand = rem(Map.get(acc,:rand) * 3 + length, 51)
        strlst = [if(rem(new_rand,4)==0, do: 32, else: rem(new_rand,26) + 97) | Map.get(acc,:strlst)]
        %{strlst: strlst, rand: new_rand}
    end)
    |> Map.get(:strlst)
    |> to_string()
    # |> IO.puts()
  end

  def get_posts(filters = %{}) do
    fid =           filters[:id]
    ftitle =        filters[:title]
    ftag =          filters[:tag]
    fverified =     filters[:verified]
    fbefore_time =  filters[:before]
    fafter_time =   filters[:after]
    flimit =        filters[:limit]
    foffset =       filters[:offset]


    # create list
    post_list = for id <- Enum.to_list(0..999) do
      %{
        id: id,
        title: Db.get_string(25,id),
        content: Db.get_string(100,id),
        tag: Db.get_string(10,rem(id,5)),
        verified: rem(id**3 + 69,3) == 0,
        comment_count: rem(id**3 + 69,67),
        pr_count: rem(id**3 + 69,42),
        action_type: if(rem(id**3 + 69,5)==0, do: "pull requested", else: "commented"),
        action_content: Db.get_string(50,id),
        creation_timestamp: System.os_time(:second)-rem(id**3+69,3600*24*30),
      }
    end
    # Theres a reason I'm not writing an SQL language from scratch
    |> Enum.filter(fn i ->
      if(fid != nil, do: i[:id] == fid, else: true)
      &&
      if(ftitle != nil, do: String.contains?(i[:title],ftitle), else: true)
      &&
      if(ftag != nil, do: i[:tag]==ftag, else: true)
      &&
      if(fverified != nil, do: i[:verified]==fverified, else: true)
      &&
      if(fbefore_time != nil, do: i[:creation_timestamp] <= fbefore_time, else: true)
      &&
      if(fafter_time != nil, do: i[:creation_timestamp] >= fafter_time, else: true)
    end)
    |> Enum.slice(if(foffset == nil, do: 0, else: foffset), if(flimit == nil, do: 1000, else: flimit))
  end

end
