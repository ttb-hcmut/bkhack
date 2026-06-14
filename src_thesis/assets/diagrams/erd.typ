#import "../../lib/flplus/erd.typ" as flp

// The diagram
#let diagram={
  scale(50%, flp.diagram(
    node-fill: white, 
    node-stroke:black,
    spacing: 10pt,
    flp.r((6 ,10),<P_the_owner>          ,[Owns post]           ,(<User>,"1","="),(<Post>,"N","-")),
    flp.r((10,14),<P_the_commit>         ,[Has commit head]     ,(<Post>,"1","-"),(<Commit>,"1","=")),
    flp.r((2 ,18),<C_the_owner>          ,[Owns commit]         ,(<User>,"1","="),(<Commit>,"N","-")),
    flp.r((6 ,14),<C_the_commit>         ,[Has predecessor]     ,(<Commit>,"1","-"),(<Commit>,"1","-")),
    flp.r((10,6 ),<c_the_parent_post>    ,[Is child of post]    ,(<Comment>,"1","-"),(<Post>,"1","=")),
    flp.r((14,2 ),<c_the_parent_comment> ,[Is child of comment] ,(<Comment>,"1","-"),(<Comment>,"1","-")),
    flp.r((6 ,6 ),<c_the_commenter>      ,[Is commenter of]     ,(<User>,"1","="),(<Comment>,"N","-")),
    flp.r((2 ,2 ),<cR_the_voter>         ,[Rates comment]       ,(<User>,"N","-"),(<Comment>,"N","-")),
    flp.r((14,14),<cR_the_tag>           ,[Has tag]             ,(<Commit>,"N","-"),(<Tag>,"N","-")),
    flp.e((2 ,10),<User>, [User]),
    flp.e((10,10),<Post>, [Post]),
    flp.e((10,18),<Commit>, [Commit]),
    flp.e((10,2 ),<Comment>, [Comment]),
    flp.e((14,11),<Tag>, [Tag]),

      
    flp.k((1 ,8 ),<U_k_user_id>,[user_id],<User>),
    flp.f((1 ,9 ) ,<U_name>              ,[name]                  ,<User>          ),
    flp.f((1 ,10) ,<U_password>          ,[password]              ,<User>          ),
    flp.f((1 ,11) ,<U_email>             ,[email]                 ,<User>          ),
    flp.f((1 ,12) ,<U_role>              ,[role]                  ,<User>          ),
    flp.k((12,9 ),<P_k_post_id>,[post_id],<Post>),
    flp.f((12,10) ,<P_verified>          ,[verified]              ,<Post>          ),
    flp.f((12,11) ,<P_public>            ,[public]                ,<Post>          ),
    flp.k((9,20),<C_k_commit_id>,[commit_id],<Commit>),
    flp.f((10,20) ,<C_commit_message>    ,[commit_message]        ,<Commit>        ),
    flp.f((12,19) ,<C_post_title>        ,[post_title]            ,<Commit>        ),
    flp.f((12,18) ,<C_post_text>         ,[post_text]             ,<Commit>        ),
    flp.k((8 ,1 ),<c_k_comment_id>,[comment_id],<Comment>),
    flp.f((9 ,0 ) ,<c_content>           ,[content]               ,<Comment>       ),
    flp.f((10,0 ),<c_date_created_utc>  ,[date_created_utc]      ,<Comment>       ),
    flp.f((12,0 ),<c_post_version>       ,[post_version]          ,<Comment>       ),
    flp.f((2 ,0),<cR_rating>            ,[rating]               ,<cR_the_voter>  ),
    flp.k((14,9 ),<T_k_tag_id>,[tag_id],<Tag>),
    flp.f((18,9 ),<T_tag_name>          ,[tag_name]              ,<Tag>           ),
    flp.f((18,10),<T_tag_nick>          ,[tag_nick]              ,<Tag>           ),
    flp.f((18,11),<T_tag_color>         ,[tag_color]             ,<Tag>           )
  ))
}