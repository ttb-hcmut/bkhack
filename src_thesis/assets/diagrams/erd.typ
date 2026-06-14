#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge
#import fletcher.shapes: ellipse, parallelogram, diamond, hexagon, brace

#let c = (orange, red, green, blue).map(x => x.lighten(50%))
#let e(pos,name,title) = {
  node(pos,name: name, title, shape: rect)
}
// Fields of a thing
#let f(pos,name,title,parent) = {
  node(pos,name: name, title, shape: ellipse)
  edge(parent, name, "-")
}
#let k(pos,name,title,parent) = {
  node(pos,name: name, underline(title), shape: ellipse)
  edge(parent, name, "-")
}
#let r(pos,name,title,(p1,t1,f1),(p2,t2,f2)) = {
  node(pos,name: name, title, shape: diamond)
  edge(name, p1, f1, label:t1, label-pos:0.3, bend: if(p1==p2){-10deg}else{0deg})
  edge(name, p2, f2, label:t2, label-pos:0.1, bend: if(p1==p2){10deg}else{0deg})
}

// The diagram
#let diagram={
  scale(50%,diagram(
    node-fill: white, 
    node-stroke:black,
    spacing: 10pt,
    r((6 ,10),<P_the_owner>          ,[Owns post]           ,(<User>,"1","="),(<Post>,"N","-")),
    r((10,14),<P_the_commit>         ,[Has commit head]     ,(<Post>,"1","-"),(<Commit>,"1","=")),
    r((2 ,18),<C_the_owner>          ,[Owns commit]         ,(<User>,"1","="),(<Commit>,"N","-")),
    r((6 ,14),<C_the_commit>         ,[Has predecessor]     ,(<Commit>,"1","-"),(<Commit>,"1","-")),
    r((10,6 ),<c_the_parent_post>    ,[Is child of post]    ,(<Comment>,"1","-"),(<Post>,"1","=")),
    r((14,2 ),<c_the_parent_comment> ,[Is child of comment] ,(<Comment>,"1","-"),(<Comment>,"1","-")),
    r((6 ,6 ),<c_the_commenter>      ,[Is commenter of]     ,(<User>,"1","="),(<Comment>,"N","-")),
    r((2 ,2 ),<cR_the_voter>         ,[Rates comment]       ,(<User>,"N","-"),(<Comment>,"N","-")),
    r((14,14),<cR_the_tag>           ,[Has tag]             ,(<Commit>,"N","-"),(<Tag>,"N","-")),
    e((2 ,10),<User>, [User]),
    e((10,10),<Post>, [Post]),
    e((10,18),<Commit>, [Commit]),
    e((10,2 ),<Comment>, [Comment]),
    e((14,11),<Tag>, [Tag]),

      
    k((1 ,8 ),<U_k_user_id>,[user_id],<User>),
    f((1 ,9 ) ,<U_name>              ,[name]                  ,<User>          ),
    f((1 ,10) ,<U_password>          ,[password]              ,<User>          ),
    f((1 ,11) ,<U_email>             ,[email]                 ,<User>          ),
    f((1 ,12) ,<U_role>              ,[role]                  ,<User>          ),
    k((12,9 ),<P_k_post_id>,[post_id],<Post>),
    f((12,10) ,<P_verified>          ,[verified]              ,<Post>          ),
    f((12,11) ,<P_public>            ,[public]                ,<Post>          ),
    k((9,20),<C_k_commit_id>,[commit_id],<Commit>),
    f((10,20) ,<C_commit_message>    ,[commit_message]        ,<Commit>        ),
    f((12,19) ,<C_post_title>        ,[post_title]            ,<Commit>        ),
    f((12,18) ,<C_post_text>         ,[post_text]             ,<Commit>        ),
    k((8 ,1 ),<c_k_comment_id>,[comment_id],<Comment>),
    f((9 ,0 ) ,<c_content>           ,[content]               ,<Comment>       ),
    f((10,0 ),<c_date_created_utc>  ,[date_created_utc]      ,<Comment>       ),
    f((12,0 ),<c_post_version>       ,[post_version]          ,<Comment>       ),
    f((2 ,0),<cR_rating>            ,[rating]               ,<cR_the_voter>  ),
    k((14,9 ),<T_k_tag_id>,[tag_id],<Tag>),
    f((18,9 ),<T_tag_name>          ,[tag_name]              ,<Tag>           ),
    f((18,10),<T_tag_nick>          ,[tag_nick]              ,<Tag>           ),
    f((18,11),<T_tag_color>         ,[tag_color]             ,<Tag>           )
  ))
}