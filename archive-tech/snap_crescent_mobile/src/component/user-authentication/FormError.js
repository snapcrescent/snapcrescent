import React from 'react';
import { Text, View } from "react-native";
import { isNotNull } from "../../utils/CoreUtil";
import FormControlStyle from "./formControlStyles";

function FormError(props) {
    const { errorMessage } = props;

    return (
        <View>
            {
                isNotNull(errorMessage)
                    ? <View>
                        <Text style={FormControlStyle.errorMessage}>{errorMessage}</Text>
                    </View >
                    : null
            }
        </View>
    );

}

export default FormError;