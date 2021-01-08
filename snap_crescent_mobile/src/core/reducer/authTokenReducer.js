function authTokenReducer(state = null, action) {
    switch (action.type) {
        case "SET_AUTH_TOKEN": {
            state = action.value;
            return state;
        }

        case "REMOVE_AUTH_TOKEN": {
            state = null;
            return state;
        }

        default:
            return state;
    }
}

export default authTokenReducer;