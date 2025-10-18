const webpack = require("webpack")

const backend_address = (() => {
	switch (process.env.BKHACK_BACKEND_ADDRESS) {
	case undefined:
		const default_addr = "https://bkhack.onrender.com"
		console.log(`bkhackenv.backend_address: using default address \"${default_addr}\"`)
		return default_addr
	default:
		if (typeof process.env.BKHACK_BACKEND_ADDRESS === "string") {
			const addr = process.env.BKHACK_BACKEND_ADDRESS
			console.log(`bkhackenv.backend_address: using override \"${addr}\"`)
			return addr
		}
		throw new Error("??")
	}
})()

module.exports = {
	plugins: [
		new webpack.DefinePlugin({
			"bkhackenv.backend_address": `\"${backend_address}\"`
		})
	],
	devServer: {
		allowedHosts: "all"
	}
}
