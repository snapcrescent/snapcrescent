import React from 'react';
import { Text, TouchableOpacity, View } from 'react-native';
import Menu, { MenuDivider, MenuItem } from 'react-native-material-menu';
import FontAwesome5Icon from 'react-native-vector-icons/FontAwesome5';
import { isNotNull } from '../../../utils/CoreUtil';

function DropMenu(props) {

    const { items, icon, iconStyle, label, labelStyle } = props;
    let menu = null;

    return (
        <Menu
            ref={(ref) => { menu = ref; }}
            button={
                <TouchableOpacity
                    onPress={() => { menu?.show() }}
                    style={{ paddingHorizontal: 5, marginHorizontal: 5 }}>
                    {
                        isNotNull(label)
                            ? <Text style={{ fontSize: 20, color: '#fff', ...labelStyle }}>{label}</Text>
                            : <FontAwesome5Icon
                                name={icon ? icon : 'ellipsis-v'}
                                style={{ fontSize: 20, color: '#fff', ...iconStyle }} />
                    }
                </TouchableOpacity>
            }>

            {
                items.map(item => {
                    return (
                        <View>
                            <MenuItem onPress={() => { item.onPress() }}>{item.label}</MenuItem>
                            {
                                item.hasDivider
                                    ? <MenuDivider />
                                    : null
                            }
                        </View>
                    )
                })
            }
        </Menu>
    );
}

export default DropMenu;