import:py from jaclang.core.llms, Anthropic;
import:py os;
import:py json;
import:py from jaclang_jaseci, start;
import:py from jaclang_jaseci.plugins, specs;
import:py from jaclang_jaseci.models, User as BaseUser;

# glob ANTHROPIC_API_KEY: str = os.getenv("ANTHROPIC_API_KEY", "");
glob llm = Anthropic(model_name="claude-3-sonnet-20240229");
# print( os.getenv("ANTHROPIC_API_KEY", ""));

::py::
NULL_BYTES = bytes()

class User(BaseUser):

    class Collection(BaseUser.Collection):
        @classmethod
        def __document__(cls, doc) -> "User":
            return User.model()(
                id=str(doc.pop("_id")),
                email=doc.pop("email"),
                password=doc.pop("password", None) or NULL_BYTES,
                root_id=str(doc.pop("root_id")),
                **doc,
            )
::py::

# print(ANTHROPIC_API_KEY);
# walker get_yesterdays_tasks {
#     has status: str;
#     has tasks: list;
    
#     can filter_node with entry task {
#         self.tasks.append(task)
#     }
#     with exit {
#         return tasks;
#     }
# }

can gen_node(node_info:dict) -> day | workette | None{
    return_node: day | workette | None = None;
    if node_info["name"] == "day" {
        # print(node_info);
        # return_node = day(jid=node_info["jid"],data = node_info["context"]);
        return_node = day(jid=node_info["jid"],context = node_info["context"]);

    }elif node_info["name"] == "workette"{
        # return_node = workette(jid=node_info["jid"],data= node_info["context"]);
        return_node = workette(jid=node_info["jid"],context =node_info["context"]);
    }else{
        print("node type not supported");
    }
    return return_node;

}

node day{
    has jid: string="";
    has context:dict ={};

}

node workette{
    has jid: string="";
    has context:dict ={};
}

"""
Edges def

"""

edge parent{
    has jid:string="";
}

@specs
walker get_subtask_work{
    can start with workette entry{
        # print(here);
        self.group =here.context["name"];

        # print([<--]);

    }

}

@specs
walker get_todays_all_tasks{

    # has status: str;
    has tasks: list=[];
    
    can filter_node with `root entry{
        # self.tasks.append("");
        print("inside root node");
        self.day_nodes =[-->];
        print("All day noodes",self.day_nodes);
        # self.tasks.append(self.day_nodes[0]);
        # print("day",self.day_nodes);
        visit self.day_nodes;
    }

    can go_to_workette with day entry{
        self.workette_nodes =[-->];
        # print(self.workette_nodes);
        # print(self.workette_nodes);
        # print("middle",self.workette_nodes);
        print("All workette nodes",self.workette_nodes);
        for node_item in self.workette_nodes{
            if node_item.context["wtype"]=="workette"{
                # group = here spawn get_subtask_work();
                subtask = "something";
                group ="group";
                # print("subtask",subtask);
                # print("group\n",group);
                text = "the item is called {} it is currently {}, it is a subtask of {} and it belongs to the group {}".format(node_item.context["name"],node_item.context["status"],subtask,group);
                self.tasks.append(text);
            }
            # print(node_item.context["status"]);
        }
        # print("workette",self.workette_nodes);
        visit self.workette_nodes;
        
        # for workette_node in self.workette_nodes{
        #     # print(workette_node);
        #     visit workette_node;
        # }
    }


    async can end with workette entry{
        
        if len([-->])>0{
            self.bottom_workette_nodes =[-->];
            # print("bottom",self.bottom_workette_nodes);
            for node_item in self.bottom_workette_nodes{
                # print(node_item.context["wtype"]);

                if node_item.context["wtype"]=="workette"{
                    # subtask, group = here spawn walker();

                    second_walker = await (here spawn get_subtask_work());
                    # print(second_walker.group);
                    # subtask = "something";
                    # group ="group";
                    if (node_item.context["status"]=="running"){
                        node_item.context["status"] = "in progress";
                    }
                    text = "the item is called {}, it is currently {}, it belongs to the group called {}".format(node_item.context["name"],node_item.context["status"],second_walker.group);
                    self.tasks.append(text);
                 }
                # print(node_item.context["status"]);
            }
            
            visit self.bottom_workette_nodes;
        }
        # for workette_node in self.bottom_workette_nodes{
        #     print(workette_node);
        #     visit workette_node;
        # }
        return self.tasks;

    }
    # with exit {
    #     return tasks;
    # }

}



# walker get_todays_close_tasks{
#     has status: str;
#     has tasks: list;
    
#     can filter_node with `root entry{
#         self.tasks.append("");
#     }
#     # with exit {
#     #     return tasks;
#     # }

# }


# walker get_today_tasks {
#     has status: str;
#     has tasks: list;
    
#     can filter_node with entry task {
#         self.tasks.append(task)
#     }
#     with exit {
#         return tasks;
#     }
# }


# walker get_todays_work_tasks{
#     has status: str;
#     has tasks: list;
    
#     can filter_node with `root entry {
#         self.tasks.append("something");
#     }
#     # with exit {
#     #     return tasks;
#     # }

# }

# walker get_tasks {
#     has status: str,
#         current_date: datetime,
#         start_date: datetime,
#         end_date: datetime;
#     has tasks: list;
# }


## Graph creating
@specs
walker create_graph{
    has json_file:list =[];
    has node_list:dict={};
    # has workette_node_list:dict={};
    can go_to_day with `root entry{
        # print(self.json_file);
        x=True;
        for item in self.json_file{
            if(item[0]["jid"] not in self.node_list){
                first_node = gen_node(item[0]);
                self.node_list[first_node.jid]=first_node;
                if (x==True){
                    here ++> first_node;
                    x=False;
                }
            }
            else{
                first_node = self.node_list[item[0]["jid"]];
            }


            # Creating last node
            if(item[2]["jid"] not in self.node_list){
                last_node = gen_node(item[2]);
                self.node_list[last_node.jid]=last_node;
            }
            else{
                last_node = self.node_list[item[2]["jid"]];
            }

            edgeid=item[1]["jid"];
            
            first_node +:parent:jid=edgeid:+> last_node;
           
        }

    }




}



## Few shot examples passing to the LLM that will
glob examples: 'Walker and Argument Examples expected output for different questions': list[dict] = [
    {
        "Question": "What are the Tasks I completed yesterday",
        "expected_output": ("get_yesterdays_tasks", {
            "status": "done"
        })
    },
    {
        "Question": "How many tasks do I have open today?",
        "expected_output": ("get_todays_open_tasks", {
            "status": "open"
        })
    },
    {
        "Question": "How many tasks do I have close today?",
        "expected_output": ("get_todays_close_tasks", {
            "status": "close"
        })
    },
     {
        "Question": "Do I have any tasks that are work related today?",
        "expected_output": ("get_todays_work_tasks", {
            "status": "open"
        })
    }
];


## Call LLM first time to get the correct walker
can 'Get Walker and Arguments for the given question'
get_walker_arguments(question: "Question": str) -> 'Walker and Arguments': tuple(str, dict) by llm(incl_info(examples));

# can 'Get age for the the given person name'
# get_age_for_given_person_name(name:"Person's name":str) -> 'age':int by llm();

## Call LLM second time to get the answer for that question
can 'Get Conversational Answer and be more motivative'
get_answer(
    question: 'Question': str, 
    tasks: "Tasks Relevant to the Question":list
    ) -> 'Answer to the Question': str 
    by llm();


# ## call this function with the question of the user
# can answer_question(question: str) -> str {
#     # try {
#         (walker_name, params) = get_walker_arguments(question);
#         print("walker and parameters",walker_name,params);
#         if walker_name == "get_todays_open_tasks" {
#             tasks = root spawn get_todays_open_tasks(**params);
#         } elif  walker_name == "get_todays_work_tasks"{
#             tasks = root spawn get_todays_work_tasks(**params);
#         }elif walker_name == "get_yesterdays_tasks"{
#             tasks = root spawn get_yesterdays_tasks(**params);
#         }
#         answer = get_answer(question, tasks);
#     # } except Exception {
#     #     answer = "Sorry Something went wrong try again!";
#     # }
#     return answer;
# }

# with entry{
#     json_file = json.load(open(f"myca_buddy_testing_get_subgraph_today_0319.json", "r"));
#     # print(answer_question("how many tasks do I have open today"));
#     # print(answer_question("do I have any tasks that are work related today?"));
#     root spawn create_graph(json_file=json_file["report"][0]);
#     all_tasks = root spawn get_todays_all_tasks();
#     print(get_answer("how many tasks do I have open today?",all_tasks.tasks));
#     # print(all_tasks.tasks);
#     # print(len(all_tasks.tasks));

  
#     # root spawn create_graph(json_file=json_file["report"][0]);
#     # root spawn traverse_graph();
#     # print(dotgen(root));
# }


can server_run() {
    # json_file = json.load(open(f"myca_buddy_testing_get_subgraph_today_0319.json", "r"));
    # os.environ["LANGCHAIN_PROJECT"] = "pn-server";
    start(
        host="0.0.0.0",
        port=5000
    );
}

with entry:__main__ {
    # local_run();
    server_run();
}
