import React from 'react';
import { Text, View } from "react-native";
import { isNotNull } from "../../utils/CoreUtil";
import FormControlStyle from "./formControlStyles";

function FormError(props) {
    return (
        <View>
            {
                isNotNull(props.errorMessage)
                    ? <View>
                        <Text style={FormControlStyle.errorMessage}>{props.errorMessage}</Text>
                    </View >
                    : null
            }
        </View>
    );

}

export default FormError;