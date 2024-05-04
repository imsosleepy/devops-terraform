variable "myvar" {
    type = string 
    default = "hello terraform"
}
# Terraform v0.12 이후 버전에서는 타입 제약 조건을 문자열(quotes)로 묶는 것이 더 이상 권장되지 않습니다. 
# variable "myvar" 선언에서 type = "string" 부분의 큰따옴표를 제거
# var.myvar

variable "mymap" {
    type = map(string) 
    default = {
        mykey ="my value"
    }
}
# var.mymap
# var.mymap["mykey"]
# "${var.mymap["mykey"]}"

variable "mylist" {
    type = list
    default = [1,2,3]
}
# var.mylist[0]
# element(var.mylist, 1)
# slice(var.mylist, 0, 2)