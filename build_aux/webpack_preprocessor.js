const webpack = require("webpack")
const path = require("path")

const backend_address = (() => {
	if (process.env.BKHACK_BACKEND_ADDRESS === undefined || typeof process.env.BKHACK_BACKEND_ADDRESS !== "string") {
		throw new Error("did not specify BKHACK_BACKEND_ADDRESS")
	}
	return process.env.BKHACK_BACKEND_ADDRESS;
})()

const firebase_key = (() => {
	if (process.env.BKHACK_FIREBASE_KEY === undefined || typeof process.env.BKHACK_FIREBASE_KEY !== "string") {
		throw new Error("did not specify BKHACK_FIREBASE_KEY")
	}
	return process.env.BKHACK_FIREBASE_KEY;
})()

module.exports = {
	plugins: [
		new webpack.DefinePlugin({
			"bkhackenv.backend_address": `\"${backend_address}\"`,
			"bkhackenv.firebase_key": `\"${firebase_key}\"`,
		})
	]
}
