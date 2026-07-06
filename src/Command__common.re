type feed('ctx_a, 'ctx_b) =
	| Feed_ls: feed([`sort], [`split])
	| Split_count(feed('bx, [`split]), int): feed('bx, [`split_done])
	| Sort(feed([`sort], 'cx)) : feed([`sort_done], 'cx)

type Command__sym.tree('t, 'ctx) +=
	| Tree__feed(feed('b, 'c) as 'a) : Command__sym.tree('a, [`feed])

module Feed(S : Command__sym.S) {
	open S

	let feed = info(["feed"],
		unit(() => Tree__feed(Feed_ls)),
		~doc={|
			#feed fetches all #o.bkhack posts. |},
	);

	let split_count = fd => info(["split", "-c"],
		int_of(fd, [@warning "-8"] (i, Tree__feed(acc)) => Tree__feed(Split_count(acc, i))),
		~doc={|
			#docv controls the pagination by the order at which posts are sorted. |});

	let sort = fd => info(["sort"], unit_of(fd, [@warning "-8"] (Tree__feed(acc)) => Tree__feed(Sort(acc))));

	open Tree.Match

	register_pat(split_count(sort(feed)));
	register_pat(sort(split_count(feed)));
	register_pat(split_count(feed));
	register_pat(sort(feed));
	register_pat(feed);
}

type devbook_article =
	[]

type man('ctx) =
	| Man__devbook(devbook_article): man([`source_raw])
	| Man__wiki(string): man([`source])
	| Man__grep(man([`source | `source_filtered(string)]), string): man([`source_filtered(string)])

type Command__sym.tree('t, 'ctx) +=
	| Tree__man(man('c) as 'a) : Command__sym.tree('a, [`man])

let all : list(module Command__sym.Spec) = [
	(module Feed)
]
