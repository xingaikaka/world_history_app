import '../models/country.dart';

/// 补充人物库：键格式 `countryId|periodId|人物姓名`
/// 用于阶段 keyFigures 未收录、但需在事件节点手动绑定的人物
const Map<String, KeyFigure> supplementaryFigures = {
  // ── 中国 · 上古 ──
  'cn|cn_ancient|老子': KeyFigure(
    name: '老子',
    role: '道家学派创始人',
    description: '相传老子著《道德经》，提出"道法自然""无为而治"，与儒家互补。其思想影响中国哲学、宗教与政治伦理两千余年，也是世界思想史重要遗产。',
  ),
  'cn|cn_ancient|孟子': KeyFigure(
    name: '孟子',
    role: '儒家亚圣',
    description: '孟子发展孔子思想，提出性善论与民贵君轻，强调仁政。其言论收录于《孟子》，对后世政治伦理影响深远。',
  ),

  // ── 中国 · 秦汉至南北朝 ──
  'cn|cn_imperial_early|蒙恬': KeyFigure(
    name: '蒙恬',
    role: '秦国名将',
    description: '蒙恬率秦军北击匈奴，主持连接长城工程，是秦帝国边防体系的关键将领。其军事成就保障了统一后北方边境安全。',
  ),
  'cn|cn_imperial_early|刘邦': KeyFigure(
    name: '刘邦',
    role: '汉高祖',
    description: '刘邦在楚汉战争中击败项羽，建立汉朝，定都长安。他吸取秦亡教训，实行休养生息，奠定四百年汉业基础。',
  ),
  'cn|cn_imperial_early|卫青': KeyFigure(
    name: '卫青',
    role: '西汉大将军',
    description: '卫青七击匈奴，漠北之战大破单于，解除北方边患。其与霍去病配合，使汉朝疆域扩展至河西走廊。',
  ),
  'cn|cn_imperial_early|霍去病': KeyFigure(
    name: '霍去病',
    role: '西汉骠骑将军',
    description: '霍去病少年从军，封狼居胥，深入漠北击败匈奴。其"匈奴未灭，何以家为"成为后世尚武精神象征。',
  ),
  'cn|cn_imperial_early|蔡伦': KeyFigure(
    name: '蔡伦',
    role: '东汉宦官 · 造纸术改进者',
    description: '蔡伦改进造纸工艺，以树皮、麻头、破布等为原料，降低成本、提高质量。造纸术传播改变世界文明进程。',
  ),
  'cn|cn_imperial_early|北魏孝文帝': KeyFigure(
    name: '北魏孝文帝',
    role: '北魏改革君主',
    description: '孝文帝迁都洛阳，推行全面汉化改革，改汉姓、穿汉服、与汉族通婚，促进胡汉融合，影响北朝及隋唐政治文化。',
  ),
  'cn|cn_imperial_early|司马迁': KeyFigure(
    name: '司马迁',
    role: '史学家',
    description: '司马迁著《史记》，开创纪传体通史，被鲁迅誉为"史家之绝唱，无韵之离骚"。其史学精神与叙事艺术影响两千年。',
  ),

  // ── 中国 · 隋唐至宋元 ──
  'cn|cn_tang_song|隋炀帝': KeyFigure(
    name: '隋炀帝',
    role: '隋朝第二位皇帝',
    description: '隋炀帝开凿大运河、兴建东都洛阳，但穷兵黩武、役重民怨，导致隋末农民起义，隋朝迅速灭亡。',
  ),
  'cn|cn_tang_song|魏征': KeyFigure(
    name: '魏征',
    role: '唐太宗名臣',
    description: '魏征以直言敢谏著称，辅佐李世民开创贞观之治。其谏言体现"以人为镜"的明君贤臣政治理想。',
  ),
  'cn|cn_tang_song|杨贵妃': KeyFigure(
    name: '杨贵妃',
    role: '唐玄宗宠妃',
    description: '杨贵妃（杨玉环）为唐玄宗宠妃，其宠幸与安史之乱关联，成为盛唐由盛转衰的历史符号之一。',
  ),
  'cn|cn_tang_song|安禄山': KeyFigure(
    name: '安禄山',
    role: '安史之乱发动者',
    description: '安禄山身兼三镇节度使，755年发动叛乱，持续八年，使唐朝由盛转衰，藩镇割据加剧。',
  ),
  'cn|cn_tang_song|毕昇': KeyFigure(
    name: '毕昇',
    role: '发明家',
    description: '毕昇发明活字印刷术，以泥活字排版，极大提高书籍生产效率，推动知识传播与文艺复兴前的信息革命。',
  ),
  'cn|cn_tang_song|岳飞': KeyFigure(
    name: '岳飞',
    role: '南宋抗金名将',
    description: '岳飞率岳家军抗金，连战连捷，其"精忠报国"精神成为民族英雄象征。1142年被秦桧以莫须有罪名害死。',
  ),
  'cn|cn_tang_song|秦桧': KeyFigure(
    name: '秦桧',
    role: '南宋权相',
    description: '秦桧主和，以莫须有罪名害死岳飞，被后世视为卖国奸臣。其形象成为忠奸对立的典型符号。',
  ),
  'cn|cn_tang_song|陆秀夫': KeyFigure(
    name: '陆秀夫',
    role: '南宋忠臣',
    description: '崖山海战失败后，陆秀夫背负幼帝赵昺投海殉国，象征南宋最后抵抗。其气节成为后世忠烈叙事的重要人物。',
  ),

  // ── 中国 · 明清 ──
  'cn|cn_ming_qing|朱棣': KeyFigure(
    name: '朱棣',
    role: '明成祖',
    description: '朱棣发动靖难之役即位，迁都北京，派郑和七下西洋，编修《永乐大典》，开创明朝前期强盛局面。',
  ),
  'cn|cn_ming_qing|多尔衮': KeyFigure(
    name: '多尔衮',
    role: '清初摄政王',
    description: '多尔衮在清初入主中原中发挥关键作用，率清军入关，推行剃发易服等政策，奠定清朝统治基础。',
  ),
  'cn|cn_ming_qing|乾隆帝': KeyFigure(
    name: '乾隆帝',
    description: '乾隆帝在位六十年，版图达于极盛，编修《四库全书》，但后期闭关锁国、文字狱与腐败为衰落埋下隐患。',
    role: '清高宗',
  ),
  'cn|cn_ming_qing|李鸿章': KeyFigure(
    name: '李鸿章',
    role: '洋务派领袖',
    description: '李鸿章主持洋务运动，创办近代工业与海军，代表清政府多次对外谈判。其功过评价在近代史研究中争议极大。',
  ),
  'cn|cn_ming_qing|康有为': KeyFigure(
    name: '康有为',
    role: '维新派领袖',
    description: '康有为推动戊戌变法，主张君主立宪与制度变革。变法失败后流亡海外，其思想影响近代中国政治改革讨论。',
  ),
  'cn|cn_ming_qing|梁启超': KeyFigure(
    name: '梁启超',
    role: '思想家 · 维新派',
    description: '梁启超是戊戌变法核心人物，后成为近代报刊政论与史学大家，其启蒙文字影响一代青年知识分子。',
  ),

  // ── 中国 · 民国 ──
  'cn|cn_modern|李大钊': KeyFigure(
    name: '李大钊',
    role: '马克思主义先驱',
    description: '李大钊在北大传播马克思主义，参与创建中国共产党，是五四时期最重要的思想启蒙者之一。1927年英勇就义。',
  ),
  'cn|cn_modern|陈独秀': KeyFigure(
    name: '陈独秀',
    role: '新文化运动旗手',
    description: '陈独秀创办《新青年》，倡导民主与科学，参与创建中国共产党并任首任总书记。其思想与政治生涯极具争议与影响。',
  ),

  // ── 日本 ──
  'jp|jp_ancient|卑弥呼': KeyFigure(
    name: '卑弥呼',
    role: '邪马台国女王',
    description: '《魏志·倭人传》记载其统合诸国并向魏朝朝贡，是研究日本早期国家形成的关键人物。',
  ),
  'jp|jp_ancient|圣德太子': KeyFigure(
    name: '圣德太子',
    role: '摄政 · 改革者',
    description: '圣德太子制定冠位十二阶、推动佛教、派遣遣隋使，被视为日本早期国家建设与文化开化的象征。',
  ),
  'jp|jp_ancient|小野妹子': KeyFigure(
    name: '小野妹子',
    role: '遣隋使',
    description: '小野妹子奉命出使隋朝，促进中日交流，其外交活动为大化改新提供制度参照。',
  ),
  'jp|jp_classical|鉴真': KeyFigure(
    name: '鉴真',
    role: '唐代高僧',
    description: '鉴真六次东渡，最终在754年抵达日本，传播律宗与建筑、医学知识，对奈良时代佛教影响深远。',
  ),
  'jp|jp_classical|紫式部': KeyFigure(
    name: '紫式部',
    role: '《源氏物语》作者',
    description: '紫式部创作《源氏物语》，被誉为世界最早长篇小说之一，代表平安时代贵族文学巅峰。',
  ),
  'jp|jp_samurai|源义经': KeyFigure(
    name: '源义经',
    role: '源平合战名将',
    description: '源义经在源平合战中屡建奇功，坛之浦之战后遭兄长源赖朝猜忌而被迫自害，成为日本悲剧英雄典型。',
  ),
  'jp|jp_samurai|织田信长': KeyFigure(
    name: '织田信长',
    role: '战国大名',
    description: '织田信长以铁炮战术革新战争，灭室町幕府，推动天下统一进程，本能寺之变后事业由丰臣秀吉继承。',
  ),
  'jp|jp_samurai|丰臣秀吉': KeyFigure(
    name: '丰臣秀吉',
    role: '关白 · 统一者',
    description: '丰臣秀吉继承织田信长事业，完成日本统一，发动文禄·庆长之役侵朝，其政权在关原之战后被德川取代。',
  ),
  'jp|jp_edo|德川家康': KeyFigure(
    name: '德川家康',
    role: '江户幕府开创者',
    description: '德川家康在关原之战获胜，1603年建立江户幕府，开启日本260余年相对和平的锁国时代。',
  ),
  'jp|jp_edo|佩里': KeyFigure(
    name: '佩里',
    role: '美国海军准将',
    description: '1853年佩里率黑船舰队抵日，迫使日本开国，结束锁国政策，间接引发明治维新。',
  ),

  'fr|fr_revolution|路易十六': KeyFigure(
    name: '路易十六',
    role: '法国末代国王',
    description: '路易十六在位期间财政危机激化，大革命爆发后于1793年被处决，象征旧制度终结。',
  ),

  // ── 希腊 ──
  'gr|gr_ancient|菲迪皮德斯': KeyFigure(
    name: '菲迪皮德斯',
    role: '马拉松信使',
    description: '传说菲迪皮德斯从马拉松跑回雅典报捷后力竭而死，马拉松赛跑由此得名。',
  ),
  'gr|gr_ancient|克利斯提尼': KeyFigure(
    name: '克利斯提尼',
    role: '雅典改革家',
    description: '克利斯提尼推行民主改革，建立地域部落与公民大会制度，被视为雅典民主政体的奠基者。',
  ),
  'gr|gr_ancient|腓力二世': KeyFigure(
    name: '腓力二世',
    role: '马其顿国王',
    description: '腓力二世改革马其顿军队，统一希腊，为儿子亚历山大大帝的东征奠定基础。',
  ),
  'gr|gr_ancient|薛西斯': KeyFigure(
    name: '薛西斯',
    role: '波斯国王',
    description: '薛西斯率波斯大军第二次入侵希腊，在萨拉米海战与普拉提亚战败，保存了希腊城邦独立。',
  ),

  // ── 美国 ──
  'us|us_revolution|托马斯·杰斐逊': KeyFigure(
    name: '托马斯·杰斐逊',
    role: '独立宣言主笔 · 第三任总统',
    description: '杰斐逊主笔独立宣言，阐述天赋人权，后任总统并完成路易斯安那购地，是美国建国核心人物之一。',
  ),
  'us|us_revolution|本杰明·富兰克林': KeyFigure(
    name: '本杰明·富兰克林',
    role: '政治家 · 科学家',
    description: '富兰克林参与独立宣言起草，出使法国争取援助，亦以科学发明与印刷出版闻名，是启蒙时代全才代表。',
  ),
  'us|us_civil_war|亚伯拉罕·林肯': KeyFigure(
    name: '亚伯拉罕·林肯',
    role: '第16任总统',
    description: '林肯领导北方赢得内战，发布《解放奴隶宣言》，维护联邦统一，1865年遇刺身亡，被尊为美国最伟大的总统之一。',
  ),

  // ── 英国 ──
  'gb|gb_medieval|西蒙·德·蒙福尔': KeyFigure(
    name: '西蒙·德·蒙福尔',
    role: '议会先驱',
    description: '1265年西蒙·德·蒙福尔召集含骑士与市民代表的议会，被视为英国议会民主发展的重要先驱。',
  ),
  'gb|gb_tudor|亨利八世': KeyFigure(
    name: '亨利八世',
    role: '都铎国王',
    description: '亨利八世脱离罗马教廷，建立英国国教，使教廷财产国有化，其六次婚姻与宗教改革深刻改变英国社会。',
  ),
  'gb|gb_tudor|伊丽莎白一世': KeyFigure(
    name: '伊丽莎白一世',
    role: '都铎女王',
    description: '伊丽莎白一世击败西班牙无敌舰队，稳定国教，扶持莎士比亚等文学繁荣，开创英国"黄金时代"。',
  ),

  // ── 印度 ──
  'in|in_ancient|释迦牟尼': KeyFigure(
    name: '释迦牟尼',
    role: '佛教创始人',
    description: '乔达摩·悉达多成道为佛陀，创立佛教，强调众生平等与八正道，成为亚洲影响最广泛的宗教之一。',
  ),
  'in|in_ancient|阿育王': KeyFigure(
    name: '阿育王',
    role: '孔雀帝国皇帝',
    description: '阿育王在卡林加战争后皈依佛教，停止扩张，以佛法治理，派遣使者传播佛教至亚洲各地。',
  ),
  'in|in_mughal|巴布尔': KeyFigure(
    name: '巴布尔',
    role: '莫卧儿帝国开创者',
    description: '巴布尔在帕尼帕特击败德里苏丹，建立莫卧儿帝国，融合中亚与印度文化，开启印度最后大型伊斯兰帝国。',
  ),
  'in|in_mughal|阿克巴': KeyFigure(
    name: '阿克巴',
    role: '莫卧儿皇帝',
    description: '阿克巴统一北印大部，推行宗教宽容，废除非穆斯林人头税，莫卧儿帝国最开明时期的开创者。',
  ),
  'in|in_colonial|甘地': KeyFigure(
    name: '甘地',
    role: '国大党领袖 · 非暴力主义者',
    description: '甘地以非暴力不合作运动领导印度独立斗争，盐进军等行动影响全世界民权运动，被尊为"国父"。',
  ),

  // ── 埃及 ──
  'eg|eg_pharonic|图特摩斯三世': KeyFigure(
    name: '图特摩斯三世',
    role: '新王国扩张者',
    description: '图特摩斯三世将埃及帝国扩张至叙利亚与努比亚，是新王国军事与政治巅峰的代表法老之一。',
  ),
  'eg|eg_hellenistic|克娄巴特拉七世': KeyFigure(
    name: '克娄巴特拉七世',
    role: '末代托勒密法老',
    description: '克娄巴特拉与凯撒、安东尼结盟，试图维护埃及独立，失败后自杀，托勒密王朝终结。',
  ),

  // ── 韩国 · 朝鲜王朝 ──
  'kr|kr_joseon|英祖': KeyFigure(
    name: '英祖',
    role: '朝鲜第21代国王',
    description: '英祖在位期间发生思悼世子之死，引发王室伦理悲剧与政治争议。其统治反映朝鲜王位继承与党争的残酷性。',
  ),

  // ── 俄罗斯 · 沙皇时代 ──
  'ru|ru_tsar|伊凡四世': KeyFigure(
    name: '伊凡四世',
    role: '首位沙皇',
    description: '伊凡四世（伊凡雷帝）1547年正式称沙皇，征服喀山与阿斯特拉罕，扩大东向领土，其特辖地制度强化专制但也造成国家创伤。',
  ),

  // ── 墨西哥 · 独立 ──
  'mx|mx_independent|维森特·格雷罗': KeyFigure(
    name: '维森特·格雷罗',
    role: '独立战争将领',
    description: '维森特·格雷罗与伊图尔维德达成伊瓜拉计划，完成墨西哥独立。其混血背景象征独立运动的广泛社会基础。',
  ),

  // ── 土耳其 · 奥斯曼 ──
  'tr|tr_ottoman_rise|索别斯基': KeyFigure(
    name: '索别斯基',
    role: '波兰国王',
    description: '1683年索别斯基率援军击败围攻维也纳的奥斯曼大军，此战被视为奥斯曼扩张时代的终点。',
  ),

  // ── 澳大利亚 · 原住民时代 ──
  'au|au_indigenous|詹姆斯·库克': KeyFigure(
    name: '詹姆斯·库克',
    role: '英国航海家',
    description: '1770年库克率奋进号测绘澳大利亚东岸并宣称占有，其航行奠定英国殖民法理基础，亦引发原住民主权争议。',
  ),
};
