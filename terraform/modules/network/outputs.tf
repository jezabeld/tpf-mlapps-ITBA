output "vpc_id" {
  value = aws_vpc.mwaavpc.id
}

output "pub_subnet_ids" {
  value = [aws_subnet.pubsubnets[0].id, aws_subnet.pubsubnets[1].id]
}

output "pri_subnet_ids" {
  value = [aws_subnet.prisubnets[0].id, aws_subnet.prisubnets[1].id]
}

output "ecs_subnet_ids" {
  value = [aws_subnet.prisubnets2[0].id, aws_subnet.prisubnets2[1].id]
}

output "securitygroup_id" {
  value = aws_security_group.mwaasg.id
}
output "supersetsg_id" {
  value = [aws_security_group.superset_sg.id, aws_security_group.mwaasg.id]
}