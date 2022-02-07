output "vpc_id" {
  value = aws_vpc.mwaavpc.id
}

output "pub_subnet_ids" {
  value = [aws_subnet.pubsubnets[0].id, aws_subnet.pubsubnets[1].id]
  /*[
    aws_subnet.pubsub1.id,
    aws_subnet.pubsub2.id
  ]*/
}

output "pri_subnet_ids" {
  value = [aws_subnet.prisubnets[0].id, aws_subnet.prisubnets[1].id]
  /*[
    aws_subnet.prisub1.id,
    aws_subnet.prisub2.id
  ]*/
}

output "securitygroup_id" {
  value = aws_security_group.mwaasg.id
}