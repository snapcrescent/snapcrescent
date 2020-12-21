import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';

toast.configure();

export const success = (props) =>{
    toast.success(props);
}
export const info = (props) =>{
    toast.info(props);
}
export const warning = (props) =>{
    toast.warn(props);
}
export const error = (props) =>{
    toast.error(props);
}