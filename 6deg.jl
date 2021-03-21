#!/usr/bin/env julia

import HTTP, JSON
using DataStructures

struct User
	id
	name
	depth
	prev
end

function main(apitkn, sourceusername, targetusername)
	authhdrs = ["Authorization" => "token $apitkn"]
	
	@info authhdrs
	r = HTTP.get("https://api.github.com/users/$sourceusername", authhdrs)
	obj = JSON.parse(String(HTTP.body(r)))
	sourceuser = User(obj["id"], obj["login"], 0, nothing)
	
	r = HTTP.get("https://api.github.com/users/$targetusername", authhdrs)
	obj = JSON.parse(String(HTTP.body(r)))
	targetuserid = obj["id"]
	
	queue = Queue{User}()
	enqueue!(queue, sourceuser)
	
	visited = Set{Int}()
	push!(visited, sourceuser.id)
	
	while (user = dequeue!(queue)).depth < 6
		println("Looking at user $(user.name) (depth $(user.depth))")
		r = HTTP.get("https://api.github.com/users/$(user.name)", authhdrs)
		obj = JSON.parse(String(HTTP.body(r)))
		follower_count = obj["followers"]
		pagecnt = Int(ceil(follower_count / 100))
		for i in 1:pagecnt
			r = HTTP.get("https://api.github.com/users/$(user.name)/followers?per_page=100&page=$i", authhdrs)
			data = JSON.parse(String(HTTP.body(r)))
			for obj in data
				u = User(obj["id"], obj["login"], user.depth + 1, user)
				if !(u.id in visited)
					if u.id == targetuserid
						println("Found target user at depth $(u.depth)")
						while u.id !== sourceuser.id
							print(u.name * " follows ")
							u = u.prev
						end
						println("$sourceusername")
						return
					end
					enqueue!(queue, u)
					push!(visited, u.id)
				end
			end
		end
	end
end

if length(ARGS) != 3
	println("Usage: julia 6deg.jl <api token> <source user login> <target user login>")
else
	main(ARGS...)
end
