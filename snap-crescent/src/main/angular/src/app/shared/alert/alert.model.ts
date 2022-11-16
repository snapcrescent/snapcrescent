export class Alert {
    message:string;
    type:"success" | "error";
    onClick? :Function = () => {};
}