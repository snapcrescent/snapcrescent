import { createStore } from "redux";
import allReducers from "./reducer";

const store = createStore(allReducers);

export default store;