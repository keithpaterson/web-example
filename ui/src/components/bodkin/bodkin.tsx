import {Button, FormControl, FormLabel, Input} from '@mui/joy';
//import {FontAwesomeIcon} from '@fortawesome/react-fontawesome';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import {useState} from "react";

export interface Bodkin {
    id: number;
    name: string;
}

export function Bodkins() {
    library.add(fas);

    const [bodkins, setBodkins] = useState<Bodkin[]>([]);
    const [name, setName] = useState("");

    // Table helpers -->
    function getHeadings(data:object[]) {
        return Object.keys(data[0]).map(key => {
          return <th>{key}</th>;
        });
      }
      
    // `map` over the data to return
    // row data, passing in each mapped object
    // to `getCells`
    function getRows(data:object[]) {
        return data.map(obj => {
            return <tr>{getCells(obj)}</tr>;
        });
    }
    
    // Return an array of cell data using the
    // values of each object
    function getCells(obj:object) {
        return Object.values(obj).map(value => {
            return <td>{value}</td>;
        });
    }
    // <-- end table helpers

    function handleNameChanged(event: React.FormEvent<HTMLInputElement>) {
        console.log(event)
        let val:string = event.currentTarget.value;
        setName(val)
    }

    function handleListClicked(event: React.MouseEvent<HTMLAnchorElement, MouseEvent>) {
        event.preventDefault()

        listBodkins()
            .catch(error => console.log(error))
    }

    function handleCreateClicked(event: React.MouseEvent<HTMLAnchorElement, MouseEvent>) {
        event.preventDefault()

        createBodkin({id:0, name: name})
            .catch(error => console.log(error))
    }

    function createBodkin(bodkin: Bodkin): Promise<any> {
        return fetch('http://localhost:8080/bodkins', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json;charset=UTF-8',
            },
            body: JSON.stringify(bodkin),
        })
            .then((response) => response.json)
            .then((data) => {
                return Promise.resolve(data)
            })
            //.then((data) => {
            //    console.log(data);
            //    let actual:Bodkin = {id: data?.id, name: data?.name}
            //    if (actual) {
            //        console.log(actual);
            //        return Promise.resolve(actual);
            //    }
            //    return Promise.reject(new Error('failed to create new bodkin with name "${bodkin.name}"'))
            //})
            .catch((errors) => {
                const error: Error = new Error(errors?.map((e: Error)  => e.message).join('\n') ?? 'unknown')
                return Promise.reject(error);
            })
    }
      
    function listBodkins(): Promise<Bodkin[]> {
        return fetch('http://localhost:8080/bodkins', {
            method: 'LIST',
            headers: {
                'Content-Type': 'application/json;charset=UTF-8',
            },
        })
            .then((response) => response.json())
            .then((data) => {
                console.log(data)
                setBodkins(data);
                return Promise.resolve(data)
            })
            .catch((errors) => {
                const error: Error = new Error(errors?.map((e: Error)  => e.message).join('\n') ?? 'unknown')
                return Promise.reject(error);
            })
    }

    return (
        <>
            <p>Bodkins!</p>
                
            {bodkins.length > 0 && (<div>
                <p>Current Bodkins:</p>
                <table>
                    <thead><tr>{getHeadings(bodkins)}</tr></thead>
                    <tbody><tr>{getRows(bodkins)}</tr></tbody>
                </table> 
            </div>)}
            <div>
                <FormControl>
                    <FormLabel>Name:</FormLabel>
                    <Input
                        name="name"
                        type="string"
                        placeholder="name"
                        onChange={handleNameChanged}
                    />
                </FormControl>
                <Button sx={{mt: 1}} onClick={handleCreateClicked}>
                    &nbsp;&nbsp;Create
                </Button>
            </div>
            <div>
                <Button sx={{mt: 1}} onClick={handleListClicked}>
                    &nbsp;&nbsp;List (button)
                </Button>
            </div>
        </>
    )
}

export default Bodkins