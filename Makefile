.DEFAULT_GOAL:=help
.PHONY: all help clean release major minor patch
.PRECIOUS:
SHELL:=/bin/bash

VERSION:=$(shell git describe --abbrev=0 --tags)
CURRENT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)

help:
	@echo -e "\033[33mUsage:\033[0m\n  make TARGET\n\n\033[33mTargets:\033[0m"
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[32m%-7s\033[0m %s\n", $$1, $$2}'

git_commit:
	@git add .
	@git commit -a -m "Auto" || true

git_push: git_commit
	@git push --all
	@git push --tags

bootstrap:
#	git remote add
	git remote add 0xERR0R https://github.com/0xERR0R/openvpn_exporter.git
	git remote add ablair08 https://github.com/ablair08/openvpn_exporter.git
	git remote add acedrew https://github.com/acedrew/openvpn_exporter.git
	git remote add albertogviana https://github.com/albertogviana/openvpn_exporter.git
	git remote add AnthoDingo https://github.com/AnthoDingo/openvpn_exporter.git
	git remote add benley https://github.com/benley/openvpn_exporter.git
	git remote add Blackoutt https://github.com/Blackoutt/openvpn_exporter_Alias.git
	git remote add bratislavml https://github.com/bratislavml/openvpn_exporter.git
	git remote add Brujerizmo90 https://github.com/Brujerizmo90/openvpn_exporter.git
	git remote add caarlos0-graveyard https://github.com/caarlos0-graveyard/openvpn_exporter.git
	git remote add cdhqing https://github.com/cdhqing/openvpn_exporter.git
	git remote add colixxx https://github.com/colixxx/openvpn_exporter.git
	git remote add ContentSquare https://github.com/ContentSquare/openvpn_exporter.git
	git remote add CVi https://github.com/CVi/openvpn_exporter.git
	git remote add dadowl https://github.com/dadowl/openvpn_exporter.git
	git remote add davidquarles https://github.com/davidquarles/openvpn_exporter.git
	git remote add dblia https://github.com/dblia/openvpn_exporter.git
	git remote add dglushenok https://github.com/dglushenok/openvpn_exporter.git
	git remote add doomik https://github.com/doomik/openvpn_exporter.git
	git remote add Endouble https://github.com/Endouble/openvpn_exporter.git
	git remote add freelancer https://github.com/freelancer/openvpn_exporter.git
	git remote add glebrodionov94 https://github.com/glebrodionov94/openvpn_exporter.git
	git remote add Gmax76 https://github.com/Gmax76/openvpn_exporter.git
	git remote add imker25 https://github.com/imker25/openvpn_exporter.git
	git remote add jacklicn https://github.com/jacklicn/openvpn_exporter.git
	git remote add jbkc85 https://github.com/jbkc85/openvpn_exporter.git
	git remote add jkroepke https://github.com/jkroepke/openvpn_exporter.git
	git remote add justdamilare https://github.com/justdamilare/openvpn_exporter.git
	git remote add kampka https://github.com/kampka/openvpn_exporter.git
	git remote add kishorv06 https://github.com/kishorv06/openvpn_exporter.git
	git remote add kogonia https://github.com/kogonia/openvpn_exporter.git
	git remote add lao12345 https://github.com/lao12345/openvpn_exporter.git
	git remote add lippl https://github.com/lippl/openvpn_exporter.git
	git remote add liqilong2017 https://github.com/liqilong2017/openvpn_exporter.git
	git remote add liusongWtu https://github.com/liusongWtu/openvpn_exporter.git
	git remote add luisriverag https://github.com/luisriverag/openvpn_exporter.git
	git remote add lukasCoppens https://github.com/lukasCoppens/openvpn_exporter.git
	git remote add luzrain https://github.com/luzrain/openvpn_exporter.git
	git remote add maksim77 https://github.com/maksim77/openvpn_exporter.git
	git remote add MaxTyutyunnikov https://github.com/MaxTyutyunnikov/openvpn_exporter.git
	git remote add max-wittig https://github.com/max-wittig/openvpn_exporter.git
	git remote add mayflower https://github.com/mayflower/openvpn_exporter.git
	git remote add mcbridet https://github.com/mcbridet/openvpn_exporter.git
	git remote add misterklister https://github.com/misterklister/openvpn_exporter.git
	git remote add moldis https://github.com/moldis/openvpn_exporter.git
	git remote add m-pavel https://github.com/m-pavel/openvpn_exporter.git
	git remote add notfromstatefarm https://github.com/notfromstatefarm/openvpn_exporter.git
	git remote add paranoidd https://github.com/paranoidd/openvpn_exporter.git
	git remote add pauldeng https://github.com/pauldeng/openvpn_exporter.git
	git remote add pedrorvd https://github.com/pedrorvd/openvpn_exporter.git
	git remote add phyber https://github.com/phyber/openvpn_exporter.git
	git remote add pieterlange https://github.com/pieterlange/openvpn_exporter.git
	git remote add potorciprian https://github.com/potorciprian/openvpn_exporter.git
	git remote add psvmcc https://github.com/psvmcc/openvpn_exporter.git
	git remote add pt-studio https://github.com/pt-studio/openvpn_exporter.git
	git remote add rahul67 https://github.com/rahul67/openvpn_exporter.git
	git remote add rajatvig https://github.com/rajatvig/openvpn_exporter.git
	git remote add rayjanoka https://github.com/rayjanoka/openvpn_exporter.git
	git remote add revverse https://github.com/revverse/openvpn_exporter.git
	git remote add rmrustem https://github.com/rmrustem/openvpn_exporter.git
	git remote add saady https://github.com/saady/openvpn_exporter.git
	git remote add SergeiKlyuchko https://github.com/SergeiKlyuchko/openvpn_exporter.git
	git remote add Sindweller https://github.com/Sindweller/openvpn_exporter.git
	git remote add Sispheor https://github.com/Sispheor/openvpn_exporter-1.git
	git remote add sjkimberley https://github.com/sjkimberley/openvpn_exporter.git
	git remote add solidnerd https://github.com/solidnerd/openvpn_exporter.git
	git remote add splack https://github.com/splack/openvpn_exporter.git
	git remote add Steel551454 https://github.com/Steel551454/openvpn_exporter.git
	git remote add StuartApp https://github.com/StuartApp/openvpn_exporter.git
	git remote add SwannCroiset https://github.com/SwannCroiset/openvpn_exporter.git
	git remote add Tedyst https://github.com/Tedyst/openvpn_exporter.git
	git remote add theohbrothers https://github.com/theohbrothers/openvpn_exporter.git
	git remote add tobiasneidig https://github.com/tobiasneidig/openvpn_exporter.git
	git remote add TomasVojacek https://github.com/TomasVojacek/openvpn-exporter.git
	git remote add vgeorgio https://github.com/vgeorgio/openvpn_exporter.git
	git remote add victoroloan https://github.com/victoroloan/openvpn_exporter.git
	git remote add vvlasenko-ua https://github.com/vvlasenko-ua/prometheus_openvpn_exporter.git
	git remote add wandera https://github.com/wandera/openvpn_exporter.git
	git remote add weikinhuang https://github.com/weikinhuang/openvpn_exporter.git
	git remote add wellbastos https://github.com/wellbastos/openvpn_exporter.git
	git remote add wengych https://github.com/wengych/openvpn_exporter.git
	git remote add whantt https://github.com/whantt/openvpn_exporter.git
	git remote add wq253702768 https://github.com/wq253702768/openvpn_exporter.git
	git remote add x3rus https://github.com/x3rus/openvpn_exporter.git
	git remote add xose https://github.com/xose/openvpn_exporter.git
	git remote add yimao https://github.com/yimao/openvpn_exporter.git
	git remote add yiyu123456 https://github.com/yiyu123456/openvpn_exporter.git
	git remote add younishd https://github.com/younishd/openvpn_exporter.git
	git remote add yuanzl https://github.com/yuanzl/openvpn_exporter.git
	git remote add zeroisme https://github.com/zeroisme/openvpn_exporter.git
	git remote add Zompaktu https://github.com/Zompaktu/openvpn_exporter.git

workdirs:
	git worktree add ../openvpn_exporter.0xERR0R; cd ../openvpn_exporter.0xERR0R; git checkout 0xERR0R/master
	git worktree add ../openvpn_exporter.ablair08; cd ../openvpn_exporter.ablair08; git checkout ablair08/master
	git worktree add ../openvpn_exporter.acedrew; cd ../openvpn_exporter.acedrew; git checkout acedrew/master
	git worktree add ../openvpn_exporter.albertogviana; cd ../openvpn_exporter.albertogviana; git checkout albertogviana/master
	git worktree add ../openvpn_exporter.AnthoDingo; cd ../openvpn_exporter.AnthoDingo; git checkout AnthoDingo/master
	git worktree add ../openvpn_exporter.benley; cd ../openvpn_exporter.benley; git checkout benley/master
	git worktree add ../openvpn_exporter.Blackoutt; cd ../openvpn_exporter.Blackoutt; git checkout Blackoutt/master
	git worktree add ../openvpn_exporter.bratislavml; cd ../openvpn_exporter.bratislavml; git checkout bratislavml/master
	git worktree add ../openvpn_exporter.Brujerizmo90; cd ../openvpn_exporter.Brujerizmo90; git checkout Brujerizmo90/master
	git worktree add ../openvpn_exporter.caarlos0-graveyard; cd ../openvpn_exporter.caarlos0-graveyard; git checkout caarlos0-graveyard/master
	git worktree add ../openvpn_exporter.cdhqing; cd ../openvpn_exporter.cdhqing; git checkout cdhqing/master
	git worktree add ../openvpn_exporter.colixxx; cd ../openvpn_exporter.colixxx; git checkout colixxx/master
	git worktree add ../openvpn_exporter.ContentSquare; cd ../openvpn_exporter.ContentSquare; git checkout ContentSquare/master
	git worktree add ../openvpn_exporter.CVi; cd ../openvpn_exporter.CVi; git checkout CVi/master
	git worktree add ../openvpn_exporter.dadowl; cd ../openvpn_exporter.dadowl; git checkout dadowl/master
	git worktree add ../openvpn_exporter.davidquarles; cd ../openvpn_exporter.davidquarles; git checkout davidquarles/master
	git worktree add ../openvpn_exporter.dblia; cd ../openvpn_exporter.dblia; git checkout dblia/master
	git worktree add ../openvpn_exporter.dglushenok; cd ../openvpn_exporter.dglushenok; git checkout dglushenok/master
	git worktree add ../openvpn_exporter.doomik; cd ../openvpn_exporter.doomik; git checkout doomik/master
	git worktree add ../openvpn_exporter.Endouble; cd ../openvpn_exporter.Endouble; git checkout Endouble/master
	git worktree add ../openvpn_exporter.freelancer; cd ../openvpn_exporter.freelancer; git checkout freelancer/master
	git worktree add ../openvpn_exporter.glebrodionov94; cd ../openvpn_exporter.glebrodionov94; git checkout glebrodionov94/master
	git worktree add ../openvpn_exporter.Gmax76; cd ../openvpn_exporter.Gmax76; git checkout Gmax76/master
	git worktree add ../openvpn_exporter.imker25; cd ../openvpn_exporter.imker25; git checkout imker25/master
	git worktree add ../openvpn_exporter.jacklicn; cd ../openvpn_exporter.jacklicn; git checkout jacklicn/master
	git worktree add ../openvpn_exporter.jbkc85; cd ../openvpn_exporter.jbkc85; git checkout jbkc85/master
	git worktree add ../openvpn_exporter.jkroepke; cd ../openvpn_exporter.jkroepke; git checkout jkroepke/master
	git worktree add ../openvpn_exporter.justdamilare; cd ../openvpn_exporter.justdamilare; git checkout justdamilare/master
	git worktree add ../openvpn_exporter.kampka; cd ../openvpn_exporter.kampka; git checkout kampka/master
	git worktree add ../openvpn_exporter.kishorv06; cd ../openvpn_exporter.kishorv06; git checkout kishorv06/master
	git worktree add ../openvpn_exporter.kogonia; cd ../openvpn_exporter.kogonia; git checkout kogonia/master
	git worktree add ../openvpn_exporter.lao12345; cd ../openvpn_exporter.lao12345; git checkout lao12345/master
	git worktree add ../openvpn_exporter.lippl; cd ../openvpn_exporter.lippl; git checkout lippl/master
	git worktree add ../openvpn_exporter.liqilong2017; cd ../openvpn_exporter.liqilong2017; git checkout liqilong2017/master
	git worktree add ../openvpn_exporter.liusongWtu; cd ../openvpn_exporter.liusongWtu; git checkout liusongWtu/master
	git worktree add ../openvpn_exporter.luisriverag; cd ../openvpn_exporter.luisriverag; git checkout luisriverag/master
	git worktree add ../openvpn_exporter.lukasCoppens; cd ../openvpn_exporter.lukasCoppens; git checkout lukasCoppens/master
	git worktree add ../openvpn_exporter.luzrain; cd ../openvpn_exporter.luzrain; git checkout luzrain/master
	git worktree add ../openvpn_exporter.maksim77; cd ../openvpn_exporter.maksim77; git checkout maksim77/master
	git worktree add ../openvpn_exporter.MaxTyutyunnikov; cd ../openvpn_exporter.MaxTyutyunnikov; git checkout MaxTyutyunnikov/master
	git worktree add ../openvpn_exporter.max-wittig; cd ../openvpn_exporter.max-wittig; git checkout max-wittig/master
	git worktree add ../openvpn_exporter.mayflower; cd ../openvpn_exporter.mayflower; git checkout mayflower/master
	git worktree add ../openvpn_exporter.mcbridet; cd ../openvpn_exporter.mcbridet; git checkout mcbridet/master
	git worktree add ../openvpn_exporter.misterklister; cd ../openvpn_exporter.misterklister; git checkout misterklister/master
	git worktree add ../openvpn_exporter.moldis; cd ../openvpn_exporter.moldis; git checkout moldis/master
	git worktree add ../openvpn_exporter.m-pavel; cd ../openvpn_exporter.m-pavel; git checkout m-pavel/master
	git worktree add ../openvpn_exporter.notfromstatefarm; cd ../openvpn_exporter.notfromstatefarm; git checkout notfromstatefarm/master
	git worktree add ../openvpn_exporter.paranoidd; cd ../openvpn_exporter.paranoidd; git checkout paranoidd/master
	git worktree add ../openvpn_exporter.pauldeng; cd ../openvpn_exporter.pauldeng; git checkout pauldeng/master
	git worktree add ../openvpn_exporter.pedrorvd; cd ../openvpn_exporter.pedrorvd; git checkout pedrorvd/master
	git worktree add ../openvpn_exporter.phyber; cd ../openvpn_exporter.phyber; git checkout phyber/master
	git worktree add ../openvpn_exporter.pieterlange; cd ../openvpn_exporter.pieterlange; git checkout pieterlange/master
	git worktree add ../openvpn_exporter.potorciprian; cd ../openvpn_exporter.potorciprian; git checkout potorciprian/master
	git worktree add ../openvpn_exporter.psvmcc; cd ../openvpn_exporter.psvmcc; git checkout psvmcc/master
	git worktree add ../openvpn_exporter.pt-studio; cd ../openvpn_exporter.pt-studio; git checkout pt-studio/master
	git worktree add ../openvpn_exporter.rahul67; cd ../openvpn_exporter.rahul67; git checkout rahul67/master
	git worktree add ../openvpn_exporter.rajatvig; cd ../openvpn_exporter.rajatvig; git checkout rajatvig/master
	git worktree add ../openvpn_exporter.rayjanoka; cd ../openvpn_exporter.rayjanoka; git checkout rayjanoka/master
	git worktree add ../openvpn_exporter.revverse; cd ../openvpn_exporter.revverse; git checkout revverse/master
	git worktree add ../openvpn_exporter.rmrustem; cd ../openvpn_exporter.rmrustem; git checkout rmrustem/master
	git worktree add ../openvpn_exporter.saady; cd ../openvpn_exporter.saady; git checkout saady/master
	git worktree add ../openvpn_exporter.SergeiKlyuchko; cd ../openvpn_exporter.SergeiKlyuchko; git checkout SergeiKlyuchko/master
	git worktree add ../openvpn_exporter.Sindweller; cd ../openvpn_exporter.Sindweller; git checkout Sindweller/master
	git worktree add ../openvpn_exporter.Sispheor; cd ../openvpn_exporter.Sispheor; git checkout Sispheor/master
	git worktree add ../openvpn_exporter.sjkimberley; cd ../openvpn_exporter.sjkimberley; git checkout sjkimberley/master
	git worktree add ../openvpn_exporter.solidnerd; cd ../openvpn_exporter.solidnerd; git checkout solidnerd/master
	git worktree add ../openvpn_exporter.splack; cd ../openvpn_exporter.splack; git checkout splack/master
	git worktree add ../openvpn_exporter.Steel551454; cd ../openvpn_exporter.Steel551454; git checkout Steel551454/master
	git worktree add ../openvpn_exporter.StuartApp; cd ../openvpn_exporter.StuartApp; git checkout StuartApp/master
	git worktree add ../openvpn_exporter.SwannCroiset; cd ../openvpn_exporter.SwannCroiset; git checkout SwannCroiset/master
	git worktree add ../openvpn_exporter.Tedyst; cd ../openvpn_exporter.Tedyst; git checkout Tedyst/master
	git worktree add ../openvpn_exporter.theohbrothers; cd ../openvpn_exporter.theohbrothers; git checkout theohbrothers/master
	git worktree add ../openvpn_exporter.tobiasneidig; cd ../openvpn_exporter.tobiasneidig; git checkout tobiasneidig/master
	git worktree add ../openvpn_exporter.TomasVojacek; cd ../openvpn_exporter.TomasVojacek; git checkout TomasVojacek/master
	git worktree add ../openvpn_exporter.vgeorgio; cd ../openvpn_exporter.vgeorgio; git checkout vgeorgio/master
	git worktree add ../openvpn_exporter.victoroloan; cd ../openvpn_exporter.victoroloan; git checkout victoroloan/master
	git worktree add ../openvpn_exporter.vvlasenko-ua; cd ../openvpn_exporter.vvlasenko-ua; git checkout vvlasenko-ua/master
	git worktree add ../openvpn_exporter.wandera; cd ../openvpn_exporter.wandera; git checkout wandera/master
	git worktree add ../openvpn_exporter.weikinhuang; cd ../openvpn_exporter.weikinhuang; git checkout weikinhuang/master
	git worktree add ../openvpn_exporter.wellbastos; cd ../openvpn_exporter.wellbastos; git checkout wellbastos/master
	git worktree add ../openvpn_exporter.wengych; cd ../openvpn_exporter.wengych; git checkout wengych/master
	git worktree add ../openvpn_exporter.whantt; cd ../openvpn_exporter.whantt; git checkout whantt/master
	git worktree add ../openvpn_exporter.wq253702768; cd ../openvpn_exporter.wq253702768; git checkout wq253702768/master
	git worktree add ../openvpn_exporter.x3rus; cd ../openvpn_exporter.x3rus; git checkout x3rus/master
	git worktree add ../openvpn_exporter.xose; cd ../openvpn_exporter.xose; git checkout xose/master
	git worktree add ../openvpn_exporter.yimao; cd ../openvpn_exporter.yimao; git checkout yimao/master
	git worktree add ../openvpn_exporter.yiyu123456; cd ../openvpn_exporter.yiyu123456; git checkout yiyu123456/master
	git worktree add ../openvpn_exporter.younishd; cd ../openvpn_exporter.younishd; git checkout younishd/master
	git worktree add ../openvpn_exporter.yuanzl; cd ../openvpn_exporter.yuanzl; git checkout yuanzl/master
	git worktree add ../openvpn_exporter.zeroisme; cd ../openvpn_exporter.zeroisme; git checkout zeroisme/master
	git worktree add ../openvpn_exporter.Zompaktu; cd ../openvpn_exporter.Zompaktu; git checkout Zompaktu/master
