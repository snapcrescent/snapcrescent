export const isNotNull = (value) => {
    if (value &&
        value != null &&
        value != undefined) {

        if (typeof value == 'string') {
            return value.length > 0;
        }

        return true;
    }

    return false;
}

export const isNull = (value) => {
    return !isNotNull(value);
}