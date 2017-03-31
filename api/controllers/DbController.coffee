actionUtil = require 'sails/lib/hooks/blueprints/actionUtil'
backup = require 'mongodb-backup'
restore = require 'mongodb-restore'

module.exports =
	create: (req, res) ->
		Model = actionUtil.parseModel(req)
		data = actionUtil.parseValues(req)
			
		Model.create(data)
			.then (model) ->
				sails.services.db.add data
				res.created(model)
			.catch res.serverError
			
	update: (req, res) ->
		pk = actionUtil.requirePk(req)
		Model = actionUtil.parseModel(req)
		data = actionUtil.parseValues(req)
		Model
			.update({id: pk},data)
      		.then (updatedInstance) ->
				sails.services.db.update data
				res.ok()
			.catch res.serverError		
			
	destroy: (req, res) ->
		pk = actionUtil.requirePk(req)
		Model = actionUtil.parseModel(req)

		Model.destroy({id: pk})
			.then (records) ->
				sails.services.db.remove records[0]
				res.ok()
			.catch res.serverError
			
	findByMe: (req, res) ->
		sails.services.crud
			.find(req)
			.then res.ok
			.catch res.serverError

	export: (req, res) ->
		pk = actionUtil.requirePk req
		Model = actionUtil.parseModel(req)
		Model.findOne(pk)
			.populateAll()
			.then (result) ->
				sails.log.info "backup db: #{process.env.DBURL}#{result.name} to path: #{process.env.BkDIR}"
				opts = 
					uri: "#{process.env.DBURL}#{result.name}"
					root: "#{process.env.BkDIR}"
				backup opts
				res.ok()
			.catch res.serverError
	import: (req, res) ->
		pk = actionUtil.requirePk req
		Model = actionUtil.parseModel(req)
		Model.findOne(pk)
			.populateAll()
			.then (result) ->
				sails.log.info "restore db: #{process.env.DBURL}#{result.name}_restore from: #{process.env.BkDIR}/#{result.name}"
				opts2 = 
					uri: "#{process.env.DBURL}#{result.name}_restore"
					root: "#{process.env.BkDIR}/#{result.name}"
				restore opts2
				res.ok()
			.catch res.serverError
