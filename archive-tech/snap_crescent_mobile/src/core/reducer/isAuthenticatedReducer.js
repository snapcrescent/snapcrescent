function isAuthenticatedReducer(state = false, action) {
    switch (action.type) {
        case 'AUTHENTICATED':
            return true;

        case 'NOT_AUTHENTICATED':
            return false;

        default:
            return state;
    }
}

export default isAuthenticatedReducer;