type feed('ctx_a, 'ctx_b) =
	| Feed_ls: feed([`sort], [`split])
	| Split_count(feed('bx, [`split]), int): feed('bx, [`split_done])
	| Sort(feed([`sort], 'cx)) : feed([`sort_done], 'cx)

type Command__sym.tree('t, 'ctx) +=
	| Tree__feed(feed('b, 'c)) : Command__sym.tree(feed('b, 'c), [`feed])

module Feed(S : Command__sym.S) {
	open S

	let feed = info(["feed"], unit(() => Tree__feed(Feed_ls)));

	[@warning "-8"]
	let split_count = feed => info(["split", "-c"], int_of(feed, (i, Tree__feed(acc)) => Tree__feed(Split_count(acc, i))));

	[@warning "-8"]
	let sort = feed => info(["sort"], unit_of(feed, (Tree__feed(acc)) => Tree__feed(Sort(acc))));

	open Tree.Match

	register_pat(split_count(sort(feed)));
	register_pat(sort(split_count(feed)));
	register_pat(split_count(feed));
	register_pat(sort(feed));
	register_pat(feed);
}

let all : list(module Command__sym.Spec) = [
	(module Feed)
]
