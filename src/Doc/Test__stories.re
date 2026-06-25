open Bkhack

let default = Js__storybook.meta(~component=Test.make, ~title="FDS", ());

let primary = {
	let play = env => Fetch__syntax.({
		let canvas = Js__storybook.player_canvas(env);
		let* () = Js__storybook.test_finish ( Js__storybook.test->Js__storybook.test_expect(canvas->Js__storybook.canvas_getbyrole("display"))->Js__storybook.test_tobeinthedocument );
		let* () = Js__storybook.test_finish ( Js__storybook.test->Js__storybook.test_expect(canvas->Js__storybook.canvas_getbyrole("display"))->Js__storybook.test_tobeinthedocument );
		let* () = Js__storybook.test_finish ( Js__storybook.test->Js__storybook.test_expect(canvas->Js__storybook.canvas_getbyrole("display"))->Js__storybook.test_tobeinthedocument );
		return(())
	});
	Js__storybook.story(
		~args=Test.makeProps(~alt=false, ()), ~play, ())
}
